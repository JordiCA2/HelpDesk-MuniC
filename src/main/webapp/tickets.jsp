<%-- 
    Document   : tickets
    Created on : 3 mar 2026, 17:00:07
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tickets — Sistema de Soporte</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased">
<%
  jakarta.servlet.http.HttpSession s = request.getSession(false);
  Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
  if (rol == null || (rol.intValue() != 1 && rol.intValue() != 2)) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
%>
  <header class="bg-white shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-slate-900 font-semibold tracking-tight">Tickets</span>
      </div>
      <nav class="hidden sm:flex items-center gap-2">
        <a href="admin.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Panel</a>
        <a href="reportes.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Reportes</a>
        <a href="inventario.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Inventario</a>
        <a href="seguridad/logout" class="inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold text-slate-900">Todos los Tickets</h2>
      </div>
      <div id="ticketsList" class="mt-4 divide-y divide-slate-100"></div>
    </section>
  </main>
  <script>
    function badge(estado) {
      const e = (estado || '').toLowerCase();
      if (e.includes('final')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Finalizado' };
      if (e.includes('resuel')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Resuelto' };
      if (e.includes('atenci') || e.includes('proce')) return { cls: 'bg-amber-100 text-amber-700', txt: 'En Atención' };
      return { cls: 'bg-slate-100 text-slate-700', txt: estado || 'Pendiente' };
    }
    function loadTickets() {
      fetch('ticket/gestionar?accion=listar', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const cont = document.getElementById('ticketsList');
          const items = (data && data.tickets) ? data.tickets : [];
          cont.innerHTML = items.map(x => {
            const bb = badge(x.estado);
            const who = x.solicitante ? x.solicitante : '—';
            const te = x.tecnico ? x.tecnico : '—';
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">Sol: ${who} • Tec: ${te} • ${x.fecha_registro || ''}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
        });
    }
    document.addEventListener('DOMContentLoaded', loadTickets);
  </script>
</body>
</html>
