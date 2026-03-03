<%-- 
    Document   : asistente
    Created on : 2 mar 2026, 17:00:10
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Asistente — Sistema de Soporte e Inventario</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased">
<%
  jakarta.servlet.http.HttpSession s = request.getSession(false);
  Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
  if (rol == null || rol.intValue() != 2) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
%>
  <header class="bg-white shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <img src="/assets/logo-muni-cocachacra.svg" alt="Municipalidad Distrital de Cocachacra" class="h-8 w-auto">
        <span class="text-slate-900 font-semibold tracking-tight">Panel Técnico</span>
      </div>
      <nav class="hidden sm:flex items-center gap-2">
        <a href="tickets.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Tickets</a>
        <a href="inventario.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Inventario</a>
        <a href="reportes.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Reportes</a>
        <a href="seguridad/logout" class="inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="grid grid-cols-1 sm:grid-cols-3 gap-6">
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Tickets Abiertos</div>
        <div id="kpiAbiertos" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Insumos por Agotarse</div>
        <div id="kpiInsumos" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="text-sm text-slate-600">Finalizados Hoy</div>
        <div id="kpiHoy" data-target="0" class="mt-1 text-3xl font-bold text-slate-900">0</div>
      </div>
    </section>
    <section class="mt-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold text-slate-900">Últimos Tickets</h2>
        <a href="tickets.jsp" class="text-sm text-blue-600 hover:underline">Ver todos</a>
      </div>
      <div id="lastTicketsList" class="mt-4 divide-y divide-slate-100"></div>
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
          <h2 class="text-lg font-semibold text-slate-900">Mis Reportes</h2>
        </div>
        <div id="myReportsList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
    </section>
  </main>
  <script>
    const MY_ID = (function(){ try { return <%= (Integer) request.getSession(false).getAttribute("usuarioId") %>; } catch(e) { return 0; } })();
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
    function finalizeTicket(id, btn) {
      const comentario = window.prompt('Comentario del reporte:');
      if (comentario == null) return;
      if (btn) btn.disabled = true;
      fetch('ticket/gestionar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ accion: 'finalizar', idTicket: id, comentario })
      }).then(r => {
        if (r.ok) {
          loadAll();
          loadMyReports();
        }
      }).finally(() => {
        if (btn) btn.disabled = false;
      });
    }
    function attendTicket(id, btn) {
      if (btn) btn.disabled = true;
      fetch('ticket/gestionar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ accion: 'atender', idTicket: id })
      }).then(r => {
        if (r.ok) {
          loadAll();
        }
      }).finally(() => {
        if (btn) btn.disabled = false;
      });
    }
    function loadAll() {
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
            const estadoNorm = (x.estado || '').toLowerCase();
            const isPendiente = estadoNorm === 'pendiente';
            const isEnAtencion = estadoNorm.includes('atenci');
            const action = isPendiente
              ? `<button class="inline-flex items-center rounded-md bg-amber-500 px-2.5 py-1.5 text-white text-xs hover:bg-amber-600" onclick="attendTicket(${x.id_ticket}, this)">Atender</button>`
              : (isEnAtencion
                ? `<button class="inline-flex items-center rounded-md bg-blue-600 px-2.5 py-1.5 text-white text-xs hover:bg-blue-700" onclick="finalizeTicket(${x.id_ticket}, this)">Finalizar</button>`
                : ``);
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">TK-${String(x.id_ticket).padStart(6,'0')} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">Sol: ${who} • Tec: ${te}</div>
              </div>
              <div class="flex items-center gap-2">
                <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
                ${action}
              </div>
            </div>`;
          }).join('');
        });
    }
    function loadMyReports() {
      const cont = document.getElementById('myReportsList');
      fetch('ticket/gestionar?accion=listarReportes&tecnico=' + encodeURIComponent(MY_ID), { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const items = (data && data.reportes) ? data.reportes : [];
          cont.innerHTML = items.map(x => {
            return `<div class="py-3">
              <div class="text-sm font-medium text-slate-900">TK-${String(x.id_ticket).padStart(6,'0')} • ${x.asunto}</div>
              <div class="text-xs text-slate-500">${x.fecha}</div>
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
          if (a) a.setAttribute('data-target', String((data && data.tickets_abiertos) || 0));
          if (b) b.setAttribute('data-target', String((data && data.insumos_por_agotarse) || 0));
          if (c) c.setAttribute('data-target', String((data && data.soportes_finalizados_hoy) || 0));
          [a,b,c].forEach(el => { if (el) animate(el); });
          const cont = document.getElementById('lastTicketsList');
          const items = (data && data.ultimos_tickets) ? data.ultimos_tickets : [];
          cont.innerHTML = items.map(x => {
            const bb = badge(x.estado);
            const who = x.solicitante ? x.solicitante : '—';
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">TK-${String(x.id_ticket).padStart(6,'0')} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">${who}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
        }).catch(() => {});
      loadAll();
      loadMyReports();
    });
  </script>
</body>
</html>
