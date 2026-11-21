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
  return Object.fromEntries(Object.entries(data).map(([key, value]) => [key,
    value === null ? {nullValue: null} :
    typeof value === 'boolean' ? {booleanValue: value} :
    typeof value === 'number' ? {integerValue: String(value)} : {stringValue: value},
  ]));
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
        nome: `Aluno ${key}`, matricula: registration,
        instituicaoId: institution, cursoId: null, semestreLetivo: '2026-2', periodo: 4,
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
