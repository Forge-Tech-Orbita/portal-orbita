/* ============================================================
   PORTAL ÓRBITA — SCRIPT PRINCIPAL (script.js)
   ------------------------------------------------------------
   Índice:
   1. Navegação entre telas (go, goBack, login)
   2. Relógio e saudação dinâmica
   3. Efeito do cartão de identificação (tilt + código de barras)
   4. Dados e renderização: Horário
   5. Dados e renderização: Notas
   6. Dados e renderização: Disciplinas
   ============================================================ */

/* ---------- 1. NAVEGAÇÃO ENTRE TELAS ---------- */
let history_ = ['screen-home'];
function go(id, fromNav) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    document.getElementById(id).classList.add('active');
    document.getElementById(id).scrollTop = 0;

    const nav = document.getElementById('bottomnav');
    const primary = ['screen-home', 'screen-schedule', 'screen-grades', 'screen-courses', 'screen-more'];
    if (primary.includes(id)) {
        nav.style.display = 'flex';
        document.querySelectorAll('.navbtn').forEach(b => b.classList.toggle('active', b.dataset.target === id));
    } else if (id === 'screen-login') {
        nav.style.display = 'none';
    } else {
        nav.style.display = 'none';
    }
    if (id !== 'screen-login') {
        if (history_[history_.length - 1] !== id) history_.push(id);
    } else {
        history_ = ['screen-home'];
    }
}
function goBack() {
    history_.pop();
    const prev = history_[history_.length - 1] || 'screen-home';
    go(prev);
}
function doLogin(e) {
    e.preventDefault();
    const btn = document.getElementById('loginBtn');
    btn.textContent = 'AUTENTICANDO...';
    btn.style.opacity = '.7';
    setTimeout(() => {
        btn.style.opacity = '1';
        btn.innerHTML = '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M5 12h14M13 6l6 6-6 6"/></svg> ENTRAR NO PORTAL';
        go('screen-home');
    }, 900);
    return false;
}

/* ---------- 2. RELÓGIO E SAUDAÇÃO DINÂMICA ---------- */
function updateClock() {
    const now = new Date();
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('clock').textContent = hh + ':' + mm;
    const h = now.getHours();
    const greet = h < 12 ? 'Bom dia' : (h < 18 ? 'Boa tarde' : 'Boa noite');
    document.getElementById('greetTime').textContent = greet;
}
updateClock(); setInterval(updateClock, 30000);

/* ---------- 3. EFEITO DO CARTÃO DE IDENTIFICAÇÃO (tilt + código de barras) ---------- */
const idCard = document.getElementById('idCard');
if (idCard) {
    const wrap = idCard.parentElement;
    wrap.addEventListener('mousemove', e => {
        const r = idCard.getBoundingClientRect();
        const x = (e.clientX - r.left) / r.width;
        const y = (e.clientY - r.top) / r.height;
        idCard.style.transform = `rotateY(${(x - 0.5) * 5}deg) rotateX(${(0.5 - y) * 5}deg)`;
    });
    wrap.addEventListener('mouseleave', () => { idCard.style.transform = 'rotateY(0) rotateX(0)'; });
    wrap.addEventListener('touchmove', e => {
        const t = e.touches[0]; const r = idCard.getBoundingClientRect();
        const x = (t.clientX - r.left) / r.width; const y = (t.clientY - r.top) / r.height;
        idCard.style.transform = `rotateY(${(x - 0.5) * 4}deg) rotateX(${(0.5 - y) * 4}deg)`;
    }, { passive: true });
}
/* barcode generator */
function genBarcode(el, count, maxH) {
    if (!el) return;
    let html = '';
    for (let i = 0; i < count; i++) { html += `<i style="height:${6 + Math.random() * maxH}px"></i>`; }
    el.innerHTML = html;
}
genBarcode(document.getElementById('barcode'), 14, 12);
genBarcode(document.getElementById('barcodeStrip'), 46, 28);

/* ---------- 4. DADOS E RENDERIZAÇÃO: HORÁRIO ---------- */
const schedule = {
    'SEG': [
        { t: '19:00', subj: 'Inteligência Artificial', room: 'Sala 304 · Bloco C', prof: 'Prof. R. Nakamura', color: 'var(--cyan)' },
        { t: '21:00', subj: 'Banco de Dados II', room: 'Lab 05 · Bloco B', prof: 'Prof.ª L. Andrade', color: 'var(--violet)' }
    ],
    'TER': [
        { t: '19:00', subj: 'Arquitetura de Software', room: 'Sala 210 · Bloco A', prof: 'Prof. F. Ramalho', color: 'var(--mint)' }
    ],
    'QUA': [
        { t: '19:00', subj: 'Inteligência Artificial', room: 'Sala 304 · Bloco C', prof: 'Prof. R. Nakamura', color: 'var(--cyan)' },
        { t: '21:00', subj: 'Cálculo Numérico', room: 'Sala 108 · Bloco A', prof: 'Prof. E. Villas', color: 'var(--amber)' }
    ],
    'QUI': [
        { t: '19:00', subj: 'Engenharia de Requisitos', room: 'Sala 212 · Bloco A', prof: 'Prof.ª C. Bezerra', color: 'var(--rose)' },
        { t: '21:00', subj: 'Banco de Dados II', room: 'Lab 05 · Bloco B', prof: 'Prof.ª L. Andrade', color: 'var(--violet)' }
    ],
    'SEX': [
        { t: '19:00', subj: 'Arquitetura de Software', room: 'Sala 210 · Bloco A', prof: 'Prof. F. Ramalho', color: 'var(--mint)' }
    ],
    'SÁB': []
};
const dayNames = { SEG: 'Segunda', TER: 'Terça', QUA: 'Quarta', QUI: 'Quinta', SEX: 'Sexta', 'SÁB': 'Sábado' };
const todayIdx = new Date().getDay(); // 0 sun ... 6 sat
const dayKeys = ['SÁB', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
let currentDay = dayKeys[todayIdx] || 'SEG';

function renderDayChips() {
    const wrap = document.getElementById('dayChips');
    wrap.innerHTML = Object.keys(schedule).map(d =>
        `<div class="chip ${d === currentDay ? 'active' : ''}" data-day="${d}" onclick="selectDay('${d}')">${d}</div>`
    ).join('');
}
function selectDay(d) {
    currentDay = d;
    document.querySelectorAll('#dayChips .chip').forEach(c => c.classList.toggle('active', c.dataset.day === d));
    renderClasses();
}
function renderClasses() {
    const list = schedule[currentDay] || [];
    const el = document.getElementById('classList');
    if (list.length === 0) {
        el.innerHTML = `<div class="empty-day">
      <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18"/></svg>
      <p>Sem aulas em ${dayNames[currentDay]}</p></div>`;
        return;
    }
    el.innerHTML = list.map((c, i) => `
    <div class="class-item">
      <div class="class-time">${c.t}</div>
      <div class="class-line">
        <div class="node" style="background:${c.color}; color:${c.color}"></div>
        ${i < list.length - 1 ? '<div class="stem"></div>' : ''}
      </div>
      <div class="class-card">
        <div class="subj">${c.subj}</div>
        <div class="meta"><span>${c.room}</span><span>${c.prof}</span></div>
      </div>
    </div>`).join('');
}
renderDayChips(); renderClasses();

/* ---------- 5. DADOS E RENDERIZAÇÃO: NOTAS ---------- */
const grades = [
    { subj: 'Arquitetura de Software', code: 'ESW-304', av1: 8.5, av2: 9.0, freq: 96, status: 'concluidas' },
    { subj: 'Inteligência Artificial', code: 'ESW-412', av1: 7.0, av2: 8.0, freq: 91, status: 'concluidas' },
    { subj: 'Banco de Dados II', code: 'ESW-298', av1: 6.5, av2: 7.0, freq: 88, status: 'concluidas' },
    { subj: 'Engenharia de Requisitos', code: 'ESW-355', av1: 9.0, av2: 9.5, freq: 98, status: 'concluidas' },
    { subj: 'Cálculo Numérico', code: 'MAT-210', av1: 5.5, av2: null, freq: 82, status: 'cursando' },
];
function renderGrades(filter) {
    filter = filter || 'todas';
    const el = document.getElementById('gradesList');
    const filtered = grades.filter(g => filter === 'todas' || g.status === filter);
    el.innerHTML = filtered.map((g, i) => {
        const media = g.av2 != null ? ((g.av1 + g.av2) / 2).toFixed(1) : null;
        let pillClass = 'avg-cursando', pillText = 'Cursando';
        if (media !== null) { pillClass = media >= 7 ? 'avg-high' : 'avg-mid'; pillText = media; }
        return `
    <div class="grade-card" onclick="this.classList.toggle('open')">
      <div class="gh">
        <div><div class="subj">${g.subj}</div><div class="code">${g.code}</div></div>
        <div class="avg-pill ${pillClass}">${pillText}</div>
      </div>
      <div class="grade-detail"><div class="grade-detail-in">
        <div class="gd-row"><span>AV1</span><div class="gd-bar-bg"><div class="gd-bar" style="width:${(g.av1 / 10) * 100}%"></div></div><span>${g.av1.toFixed(1)}</span></div>
        <div class="gd-row"><span>AV2</span><div class="gd-bar-bg"><div class="gd-bar" style="width:${g.av2 != null ? (g.av2 / 10) * 100 : 0}%"></div></div><span>${g.av2 != null ? g.av2.toFixed(1) : '—'}</span></div>
        <div class="freq-note">Frequência: ${g.freq}% · Situação: ${g.status === 'cursando' ? 'Em andamento' : 'Aprovado'}</div>
      </div></div>
    </div>`;
    }).join('');
}
function filterGrades(f, e) {
    document.querySelectorAll('#screen-grades .filter-row .chip').forEach(c => c.classList.remove('active'));
    e.currentTarget.classList.add('active');
    renderGrades(f);
}
renderGrades();

/* ---------- 6. DADOS E RENDERIZAÇÃO: DISCIPLINAS ---------- */
const courses = [
    { subj: 'Arquitetura de Software', prof: 'Prof. F. Ramalho', credits: 4, prog: 78, room: 'Sala 210' },
    { subj: 'Inteligência Artificial', prof: 'Prof. R. Nakamura', credits: 4, prog: 70, room: 'Sala 304' },
    { subj: 'Banco de Dados II', prof: 'Prof.ª L. Andrade', credits: 3, prog: 65, room: 'Lab 05' },
    { subj: 'Engenharia de Requisitos', prof: 'Prof.ª C. Bezerra', credits: 4, prog: 82, room: 'Sala 212' },
    { subj: 'Cálculo Numérico', prof: 'Prof. E. Villas', credits: 3, prog: 55, room: 'Sala 108' },
];
document.getElementById('coursesList').innerHTML = courses.map(c => `
  <div class="course-card">
    <div class="course-top">
      <div><div class="subj">${c.subj}</div><div class="prof">${c.prof}</div></div>
      <div class="credits-badge">${c.credits} créditos</div>
    </div>
    <div class="prog-bg"><div class="prog-fill" style="width:${c.prog}%"></div></div>
    <div class="course-foot"><span>${c.prog}% do semestre</span><span>${c.room}</span></div>
  </div>`).join('');