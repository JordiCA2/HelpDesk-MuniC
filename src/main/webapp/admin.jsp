<%-- 
    Document   : admin
    Created on : 2 mar 2026, 16:59:42
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Admin — Sistema de Soporte e Inventario</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased">
<%
  jakarta.servlet.http.HttpSession s = request.getSession(false);
  Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
  if (rol == null || rol.intValue() != 1) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
%>
  <header class="bg-white shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <img src="/assets/logo-muni-cocachacra.svg" alt="Municipalidad Distrital de Cocachacra" class="h-8 w-auto">
        <span class="text-slate-900 font-semibold tracking-tight">Administración</span>
      </div>
      <nav class="hidden sm:flex items-center gap-2">
        <a href="tickets.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Tickets</a>
        <a href="inventario.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Inventario</a>
        <a href="reportes.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Reportes</a>
        <a href="usuarios.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Usuarios</a>
        <a href="seguridad/logout" class="inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Tickets Abiertos</div>
        <div id="kpiAbiertos" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Insumos por Agotarse</div>
        <div id="kpiInsumos" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Soportes Finalizados Hoy</div>
        <div id="kpiHoy" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Tickets Totales</div>
        <div id="kpiTotal" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
    </section>
    <section class="mt-8 grid grid-cols-1 gap-6">
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-slate-900">Últimos Tickets</h2>
          <a href="tickets.jsp" class="text-sm text-blue-600 hover:underline">Ver todos</a>
        </div>
        <div id="lastTicketsList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
    </section>
    <section class="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-slate-900">Todos los Tickets</h2>
        </div>
        <div id="allTicketsList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-slate-900">Reportes de Asistentes</h2>
        </div>
        <div id="allReportsList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
    </section>
  </main>
  <script>
    function animate(el) {
      const target = parseInt(el.getAttribute('data-target'), 10) || 0;
      const duration = 900;
      const start = performance.now();
      function step(now) {
        const p = Math.min((now - start) / duration, 1);
        el.textContent = Math.floor(p * target);
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    }
    function badge(estado) {
      const e = (estado || '').toLowerCase();
      if (e.includes('resuel')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Resuelto' };
      if (e.includes('cerr')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Cerrado' };
      if (e.includes('atenci')) return { cls: 'bg-amber-100 text-amber-700', txt: 'En Atención' };
      return { cls: 'bg-slate-100 text-slate-700', txt: estado || 'Pendiente' };
    }
    function loadAllTickets() {
      fetch('ticket/gestionar?accion=listar', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const cont = document.getElementById('allTicketsList');
          const items = (data && data.tickets) ? data.tickets : [];
          const visible = items.filter(x => (x.estado || '').toLowerCase() !== 'resuelto' && (x.estado || '').toLowerCase() !== 'cerrado');
          cont.innerHTML = visible.map(x => {
            const bb = badge(x.estado);
            const who = x.solicitante ? x.solicitante : '—';
            const te = x.tecnico ? x.tecnico : '—';
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">Sol: ${who} • Tec: ${te}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
        });
    }
    function loadAllReports() {
      fetch('ticket/gestionar?accion=listarReportes', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const cont = document.getElementById('allReportsList');
          const items = (data && data.reportes) ? data.reportes : [];
          cont.innerHTML = items.map(x => {
            return `<div class="py-3">
              <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
              <div class="text-xs text-slate-500">${x.fecha} • ${x.tecnico || '—'}</div>
              <div class="text-sm text-slate-700">${x.comentario}</div>
            </div>`;
          }).join('');
        });
    }
    document.addEventListener('DOMContentLoaded', () => {
      fetch('reportes/generar', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const a = document.getElementById('kpiAbiertos');
          const b = document.getElementById('kpiInsumos');
          const c = document.getElementById('kpiHoy');
          const t = document.getElementById('kpiTotal');
          if (a) a.setAttribute('data-target', String((data && data.tickets_abiertos) || 0));
          if (b) b.setAttribute('data-target', String((data && data.insumos_por_agotarse) || 0));
          if (c) c.setAttribute('data-target', String((data && data.soportes_finalizados_hoy) || 0));
          if (t) t.setAttribute('data-target', String((data && data.tickets_total) || 0));
          [a,b,c,t].forEach(el => { if (el) animate(el); });
          const cont = document.getElementById('lastTicketsList');
          const items = (data && data.ultimos_tickets) ? data.ultimos_tickets : [];
          cont.innerHTML = items.map(x => {
            const bb = badge(x.estado);
            const who = x.solicitante ? x.solicitante : '—';
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">${who}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
        }).catch(() => {});
      loadAllTickets();
      loadAllReports();
    });
  </script>
</body>
</html>
