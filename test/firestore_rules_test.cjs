// Apenas emuladores locais; nunca usar credenciais ou endpoints de produção.
const {test, before} = require('node:test');
const assert = require('node:assert/strict');
const project = 'demo-portal-orbita';
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
assert.equal(firestoreHost, '127.0.0.1:8080');
assert.equal(authHost, '127.0.0.1:9099');
const base = `http://${firestoreHost}/v1/projects/${project}/databases/(default)/documents`;
const accounts = {};

function fields(data) {
  const encode = value =>
    value === null ? {nullValue: null} :
    typeof value === 'boolean' ? {booleanValue: value} :
    typeof value === 'number' ? (Number.isInteger(value)
      ? {integerValue: String(value)} : {doubleValue: value}) :
    typeof value === 'object' ? {mapValue: {fields: fields(value)}} :
    {stringValue: value};
  return Object.fromEntries(Object.entries(data).map(([key, value]) => [key, encode(value)]));
}

async function request(path, token, method = 'GET', data, query = '') {
  return fetch(`${base}/${path}${query}`, {
    method,
    headers: {
      ...(token ? {Authorization: `Bearer ${token}`} : {}),
      'Content-Type': 'application/json',
    },
    ...(data ? {body: JSON.stringify({fields: fields(data)})} : {}),
  });
}

before(async () => {
  for (const [key, institution, registration] of [
    ['a', 'inst-demo', '202600001'],
    ['b', 'inst-demo', '202600002'],
    ['c', 'inst-horizonte', '202600001'],
    ['orphan', 'inst-demo', '202600003'],
    ['grades-a', 'inst-demo', '202600011'],
    ['grades-b', 'inst-demo', '202600012'],
    ['grades-c', 'inst-horizonte', '202600011'],
    ['invalid', 'inst-demo', '202600013'],
  ]) {
    const response = await fetch(`http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=emulator`, {
      method: 'POST', headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        email: `${institution}.${registration}@auth.orbita.example`,
        // Senha aleatória e efêmera, usada apenas no emulador.
        password: require('node:crypto').randomUUID(), returnSecureToken: true,
      }),
    });
    assert.equal(response.status, 200);
    const {localId: uid, idToken: token} = await response.json();
    accounts[key] = {uid, token};
    if (key !== 'orphan') {
      const result = await request(`students/${uid}`, 'owner', 'PATCH', {
        nome: `Aluno ${key}`, matricula: key === 'invalid' ? '999' : registration,
        instituicaoId: institution,
        cursoId: key === 'grades-b' ? 'adm' : key.startsWith('grades-') || key === 'invalid' ? 'si' : null,
        semestreLetivo: '2026-2', periodo: 4,
      });
      assert.equal(result.status, 200);
    }
  }
  for (const [institution, courses] of [
    ['inst-demo', ['si', 'adm']], ['inst-horizonte', ['si']],
  ]) {
    for (const course of courses) {
      assert.equal((await request(
        `institutions/${institution}/courses/${course}`, 'owner', 'PATCH',
        {nome: course, ativo: true},
      )).status, 200);
    }
  }
  assert.equal((await request(
    `students/${accounts.a.uid}/grades/existing`, 'owner', 'PATCH', {subject: 'Teste'},
  )).status, 200);
  for (const key of ['grades-a', 'grades-b', 'grades-c', 'orphan', 'invalid']) {
    const course = key === 'grades-b' ? 'adm' : 'si';
    for (const [semester, courseId] of [
      ['2026-2', course], ['2025-2', course],
      ['2026-2', course === 'si' ? 'adm' : 'si'],
    ]) {
      assert.equal((await request(
        `students/${accounts[key].uid}/grades/${semester}_${courseId}_TEST-1`,
        'owner', 'PATCH', {
          semestreLetivo: semester, cursoId: courseId,
          subject: `Disciplina ${key}`, code: 'TEST-1',
          firstStage: {exam: 6, ted: 2.6},
          secondStage: {exam: null, ted: null, integratedAssessment: null},
          frequency: 94, status: 'inProgress',
        },
      )).status, 200);
    }
  }
});

function queryGrades(uid, token, filters = {
  semestreLetivo: '2026-2', cursoId: 'si',
}, collectionGroup = false) {
  const fieldFilters = Object.entries(filters).map(([field, value]) => ({
    fieldFilter: {
      field: {fieldPath: field}, op: 'EQUAL', value: {stringValue: value},
    },
  }));
  return fetch(`${base}${collectionGroup ? '' : `/students/${uid}`}:runQuery`, {
    method: 'POST',
    headers: {
      ...(token ? {Authorization: `Bearer ${token}`} : {}),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({structuredQuery: {
      from: [{collectionId: 'grades', ...(collectionGroup ? {allDescendants: true} : {})}],
      ...(fieldFilters.length ? {where: {compositeFilter: {op: 'AND', filters: fieldFilters}}} : {}),
    }}),
  });
}

test('consultar somente notas do UID, semestre e curso do perfil válido', async () => {
  for (const key of ['grades-a', 'grades-b', 'grades-c']) {
    const {uid, token} = accounts[key];
    const course = key === 'grades-b' ? 'adm' : 'si';
    const response = await queryGrades(uid, token, {semestreLetivo: '2026-2', cursoId: course});
    assert.equal(response.status, 200);
    const rows = await response.json();
    const documents = rows.filter(row => row.document).map(row => row.document);
    assert.equal(documents.length, 1);
    assert.equal(documents[0].fields.subject.stringValue, `Disciplina ${key}`);
    assert.equal(documents[0].fields.firstStage.mapValue.fields.ted.doubleValue, 2.6);
    assert.equal(documents[0].fields.secondStage.mapValue.fields.exam.nullValue, null);
  }
});

test('negar consulta ampla, filtros incompletos, outro semestre/curso e collection group', async () => {
  const {uid, token} = accounts['grades-a'];
  for (const filters of [
    {}, {semestreLetivo: '2026-2'}, {cursoId: 'si'},
    {semestreLetivo: '2025-2', cursoId: 'si'},
    {semestreLetivo: '2026-2', cursoId: 'adm'},
  ]) {
    assert.equal((await queryGrades(uid, token, filters)).status, 403);
  }
  assert.equal((await request(`students/${uid}/grades`, token)).status, 403);
  assert.equal((await queryGrades(uid, token, undefined, true)).status, 403);
});

test('negar consultas sem login, de terceiros, sem perfil/curso e identidade incompatível', async () => {
  const {uid} = accounts['grades-a'];
  for (const token of [undefined, accounts['grades-b'].token, accounts['grades-c'].token]) {
    assert.equal((await queryGrades(uid, token)).status, 403);
  }
  for (const key of ['orphan', 'invalid', 'c']) {
    const account = accounts[key];
    assert.equal((await queryGrades(account.uid, account.token)).status, 403);
  }
});

test('consulta não concede escrita de notas e preserva get legado', async () => {
  const {uid, token} = accounts['grades-a'];
  const path = `students/${uid}/grades/2026-2_si_TEST-1`;
  assert.equal((await request(path, token)).status, 200);
  assert.equal((await request(path, token, 'PATCH', {frequency: 100})).status, 403);
  assert.equal((await request(path, token, 'DELETE')).status, 403);
  assert.equal((await request(`students/${uid}/grades/new`, token, 'PATCH', {
    semestreLetivo: '2026-2', cursoId: 'si',
  })).status, 403);
  assert.equal((await request(`students/${accounts.orphan.uid}/grades/2026-2_si_TEST-1`,
    accounts.orphan.token)).status, 200);
});

test('perfil somente do titular; mesma matrícula em outra instituição não concede acesso', async () => {
  const {a, b, c, orphan} = accounts;
  assert.equal((await request(`students/${a.uid}`, a.token)).status, 200);
  for (const token of [undefined, b.token, c.token, orphan.token]) {
    assert.equal((await request(`students/${a.uid}`, token)).status, 403);
  }
  assert.equal((await request('students', a.token)).status, 403);
  assert.equal((await request(`students/${orphan.uid}`, orphan.token, 'PATCH', {
    matricula: '202600003', instituicaoId: 'inst-demo',
  })).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'DELETE')).status, 403);
});

test('curso pertence à instituição, deve estar ativo e só pode ser escolhido uma vez', async () => {
  const {a, c} = accounts;
  const query = '?updateMask.fieldPaths=cursoId';
  assert.equal((await request(`students/${c.uid}`, c.token, 'PATCH', {cursoId: 'adm'}, query)).status, 403);
  await request('institutions/inst-demo/courses/adm', 'owner', 'PATCH', {nome: 'Administração', ativo: false});
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', {cursoId: 'adm'}, query)).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', {cursoId: 'si'}, query)).status, 200);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', {cursoId: 'adm'}, query)).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', {cursoId: null}, query)).status, 403);
  for (const field of ['nome', 'matricula', 'instituicaoId', 'semestreLetivo', 'periodo']) {
    assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', {
      [field]: field === 'periodo' ? 5 : 'alterado',
    }, `?updateMask.fieldPaths=${field}`)).status, 403);
  }
  assert.equal((await request('institutions/inst-demo/courses/si', c.token)).status, 403);
  assert.equal((await request('institutions/inst-horizonte/courses/si', c.token)).status, 200);
});

test('titular grava apenas contato válido; terceiros e outros campos são negados', async () => {
  const {a, b} = accounts;
  const fieldsList = ['telefone', 'emailPessoal', 'cep', 'endereco'];
  const query = '?' + fieldsList.map(f => `updateMask.fieldPaths=${f}`).join('&');
  const contact = {telefone: '(11) 91234-5678', emailPessoal: 'a@exemplo.com', cep: '01310-100', endereco: 'Rua A, 1'};
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH', contact, query)).status, 200);
  assert.equal((await request(`students/${a.uid}`, b.token, 'PATCH', contact, query)).status, 403);
  assert.equal((await request(`students/${a.uid}`, undefined, 'PATCH', contact, query)).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH',
    {...contact, endereco: 'x'.repeat(201)}, query)).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH',
    {telefone: 11999999999}, '?updateMask.fieldPaths=telefone')).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH',
    {nome: 'alterado', ...contact, telefone: '(11) 90000-0000'}, query + '&updateMask.fieldPaths=nome')).status, 403);
  assert.equal((await request(`students/${a.uid}`, a.token, 'PATCH',
    {matricula: '1'}, '?updateMask.fieldPaths=matricula')).status, 403);
});

test('preservar get de notas; negar list, escrita e acesso de terceiros', async () => {
  const {a, b, orphan} = accounts;
  const path = `students/${a.uid}/grades/existing`;
  assert.equal((await request(path, a.token)).status, 200);
  assert.equal((await request(path, b.token)).status, 403);
  assert.equal((await request(path)).status, 403);
  assert.equal((await request(`students/${a.uid}/grades`, a.token)).status, 403);
  assert.equal((await request(path, a.token, 'PATCH', {subject: 'Alterado'})).status, 403);
  const legacyPath = `students/${orphan.uid}/grades/existing`;
  assert.equal((await request(legacyPath, 'owner', 'PATCH', {subject: 'Legado'})).status, 200);
  assert.equal((await request(legacyPath, orphan.token)).status, 200);
});

test('duas escolhas concorrentes não substituem o primeiro vínculo', async () => {
  const {b} = accounts;
  await request('institutions/inst-demo/courses/adm', 'owner', 'PATCH', {nome: 'Administração', ativo: true});
  const results = await Promise.all(['si', 'adm'].map(cursoId =>
    request(`students/${b.uid}`, b.token, 'PATCH', {cursoId}, '?updateMask.fieldPaths=cursoId')));
  assert.deepEqual(results.map(response => response.status).sort(), [200, 403]);
  assert.equal((await request('institutions/inst-demo/courses/si', b.token, 'PATCH', {ativo: false})).status, 403);
});

test('catálogo permite ler inativos, mas a consulta de ativos os exclui e isola instituições', async () => {
  const {a, c} = accounts;
  assert.equal((await request(
    'institutions/inst-demo/courses/adm', 'owner', 'PATCH',
    {nome: 'Administração', ativo: false},
  )).status, 200);
  assert.equal((await request('institutions/inst-demo/courses/adm', a.token)).status, 200);
  const query = token => fetch(`${base}/institutions/inst-demo:runQuery`, {
    method: 'POST',
    headers: {Authorization: `Bearer ${token}`, 'Content-Type': 'application/json'},
    body: JSON.stringify({
      structuredQuery: {
        from: [{collectionId: 'courses'}],
        where: {fieldFilter: {
          field: {fieldPath: 'ativo'}, op: 'EQUAL', value: {booleanValue: true},
        }},
      },
    }),
  });
  const response = await query(a.token);
  assert.equal(response.status, 200);
  const rows = await response.json();
  assert.deepEqual(
    rows.filter(row => row.document).map(row => row.document.name.split('/').at(-1)),
    ['si'],
  );
  assert.equal((await query(c.token)).status, 403);
});
