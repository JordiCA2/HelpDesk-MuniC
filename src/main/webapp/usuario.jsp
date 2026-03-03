<%-- 
    Document   : usuario
    Created on : 2 mar 2026, 17:00:26
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Usuario — Sistema de Soporte e Inventario</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased text-[17px]">
<%
  jakarta.servlet.http.HttpSession s = request.getSession(false);
  Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
  String area = s != null ? (String) s.getAttribute("usuarioNombre") : null;
  String tituloArea = (area != null && !area.isBlank()) ? (" - " + area) : "";
  if (rol == null || rol.intValue() != 3) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
%>
  <header class="bg-white shadow-md">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-5 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <img src="/assets/logo-muni-cocachacra.svg" alt="Municipalidad Distrital de Cocachacra" class="h-8 w-auto">
        <span class="text-slate-900 font-semibold tracking-tight">Panel de Usuario</span>
      </div>
      <nav class="hidden sm:flex items-center gap-2">
        <a href="seguridad/logout" class="inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="mb-8 rounded-2xl border border-slate-200 bg-gradient-to-r from-indigo-50 to-sky-50 p-6 shadow-sm">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-slate-900">Panel de Usuario<%= tituloArea %></h1>
          <p class="mt-1 text-slate-600">Gestione y cree tickets de soporte fácilmente</p>
        </div>
      </div>
    </section>
    <section class="grid grid-cols-1 sm:grid-cols-3 gap-8">
      <div class="rounded-2xl border border-slate-200 bg-white p-8 shadow transition hover:shadow-md">
        <div class="text-base text-slate-600">Tickets Abiertos</div>
        <div id="kpiAbiertos" data-target="0" class="mt-1 text-4xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-2xl border border-slate-200 bg-white p-8 shadow transition hover:shadow-md">
        <div class="text-base text-slate-600">Finalizados Hoy</div>
        <div id="kpiHoy" data-target="0" class="mt-1 text-4xl font-bold text-slate-900">0</div>
      </div>
      <div class="rounded-2xl border border-slate-200 bg-white p-8 shadow transition hover:shadow-md">
        <div class="text-base text-slate-600">Insumos por Agotarse</div>
        <div id="kpiInsumos" data-target="0" class="mt-1 text-4xl font-bold text-slate-900">0</div>
      </div>
    </section>
    <section class="mt-8 rounded-2xl border border-slate-200 bg-white p-8 shadow">
      <div class="flex items-center justify-between">
        <h2 class="text-xl sm:text-2xl font-semibold text-slate-900">Últimos Tickets</h2>
      </div>
      <div id="lastTicketsList" class="mt-4 divide-y divide-slate-100"></div>
    </section>
    <section class="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="rounded-2xl border border-slate-200 bg-white p-8 shadow">
        <h2 class="text-lg font-semibold text-slate-900">Crear Ticket</h2>
        <form id="ticketForm" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700">Categoría</label>
            <select name="idCategoria" id="selCategoria" class="mt-1 block w-full rounded-lg border-slate-300 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" required></select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">Asunto</label>
            <select name="asunto" id="selAsunto" class="mt-1 block w-full rounded-lg border-slate-300 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" required disabled>
              <option value="" disabled selected>Seleccione categoría primero</option>
            </select>
            <input type="text" id="asuntoOtro" class="mt-2 hidden w-full rounded-lg border-slate-300 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" placeholder="Especifique el asunto" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">Prioridad</label>
            <select name="idPrioridad" id="selPrioridad" class="mt-1 block w-full rounded-lg border-slate-300 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" required></select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">Descripción (opcional)</label>
            <textarea name="descripcion" rows="4" class="mt-1 block w-full rounded-lg border-slate-300 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"></textarea>
          </div>
          <div class="flex justify-end">
            <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-5 py-2.5 text-white shadow-sm hover:bg-blue-700">Enviar</button>
          </div>
        </form>
      </div>
      <div class="rounded-2xl border border-slate-200 bg-white p-8 shadow">
        <h2 class="text-lg font-semibold text-slate-900">Mis Tickets</h2>
        <div id="myTicketsList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
    </section>
  </main>
  <script>
    const MY_ID = (function(){ try { return <%= (Integer) request.getSession(false).getAttribute("usuarioId") %>; } catch(e) { return 0; } })();
    const MY_TICKET_IDS = new Set();
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
      if (e.includes('final')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Finalizado' };
      if (e.includes('resuel')) return { cls: 'bg-emerald-100 text-emerald-700', txt: 'Resuelto' };
      if (e.includes('proce')) return { cls: 'bg-amber-100 text-amber-700', txt: 'En Proceso' };
      return { cls: 'bg-slate-100 text-slate-700', txt: estado || 'Pendiente' };
    }
    function submitTicket(e) {
      e.preventDefault();
      const form = document.getElementById('ticketForm');
      const asuntoSel = form.asunto.value;
      let asunto = asuntoSel;
      if (asuntoSel === 'otro') {
        const otro = document.getElementById('asuntoOtro').value.trim();
        if (!otro) return;
        asunto = otro;
      }
      const descripcion = form.descripcion.value.trim();
      const idCategoria = parseInt(form.idCategoria.value, 10);
      const idPrioridad = parseInt(form.idPrioridad.value, 10);
      fetch('ticket/gestionar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          accion: 'crear',
          idSolicitante: MY_ID,
          idTecnico: 0,
          idCategoria,
          idPrioridad,
          asunto,
          descripcion,
          estado: 'Pendiente'
        })
      }).then(r => {
        if (r.ok) {
          form.reset();
          const selAs = document.getElementById('selAsunto');
          const asOtro = document.getElementById('asuntoOtro');
          if (selAs) { selAs.selectedIndex = 0; }
          if (asOtro) { asOtro.classList.add('hidden'); asOtro.value=''; }
          loadMyTickets();
        }
      });
    }
    function onCategoriaChange() {
      const catSel = document.getElementById('selCategoria');
      const asSel = document.getElementById('selAsunto');
      const asOtro = document.getElementById('asuntoOtro');
      if (!catSel || !asSel) return;
      const idCat = parseInt(catSel.value, 10);
      asSel.innerHTML = '<option value="" disabled selected>Cargando asuntos...</option>';
      asSel.disabled = true;
      if (asOtro) { asOtro.classList.add('hidden'); asOtro.value=''; }
      fetch('ticket/gestionar?accion=listarAsuntosPorCategoria&idCategoria=' + encodeURIComponent(idCat), { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const items = (data && data.asuntos) ? data.asuntos : [];
          const uniq = new Set();
          const opts = items.filter(x => {
            const k = (x.nombre || '').toLowerCase();
            if (!k || uniq.has(k)) return false;
            uniq.add(k);
            return true;
          }).map(x => `<option value="${x.nombre}">${x.nombre}</option>`);
          opts.push('<option value="otro">Otro (especificar)</option>');
          asSel.innerHTML = '<option value="" disabled selected>Seleccione asunto</option>' + opts.join('');
          asSel.disabled = false;
        }).catch(() => {
          asSel.innerHTML = '<option value="otro">Otro (especificar)</option>';
          asSel.disabled = false;
        });
    }
    function onAsuntoChange() {
      const asSel = document.getElementById('selAsunto');
      const asOtro = document.getElementById('asuntoOtro');
      if (!asSel || !asOtro) return;
      if (asSel.value === 'otro') {
        asOtro.classList.remove('hidden');
        asOtro.setAttribute('required', 'required');
      } else {
        asOtro.classList.add('hidden');
        asOtro.removeAttribute('required');
        asOtro.value = '';
      }
    }
    function loadMyTickets() {
      const cont = document.getElementById('myTicketsList');
      fetch('ticket/gestionar?accion=listar&solicitante=' + encodeURIComponent(MY_ID), { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const items = (data && data.tickets) ? data.tickets : [];
          cont.innerHTML = items.map(x => {
            const bb = badge(x.estado);
            const te = x.tecnico ? x.tecnico : '—';
            return `<div class="flex items-center justify-between py-3">
              <div>
                <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">Técnico: ${te}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
          MY_TICKET_IDS.clear();
          items.forEach(x => { if (x && typeof x.id_ticket === 'number') MY_TICKET_IDS.add(x.id_ticket); });
        });
    }
    function loadCategorias() {
      const sel = document.getElementById('selCategoria');
      if (!sel) return;
      sel.innerHTML = '<option value="">Cargando...</option>';
      fetch('ticket/gestionar?accion=listarCategorias', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const items = (data && data.categorias) ? data.categorias : [];
          sel.innerHTML = '<option value="" disabled selected>Seleccione categoría</option>' +
            items.map(x => `<option value="${x.id}">${x.nombre}</option>`).join('');
          sel.addEventListener('change', onCategoriaChange);
        }).catch(() => { sel.innerHTML = '<option value="">Error</option>'; });
    }
    function loadPrioridades() {
      const sel = document.getElementById('selPrioridad');
      if (!sel) return;
      sel.innerHTML = '<option value="">Cargando...</option>';
      fetch('ticket/gestionar?accion=listarPrioridades', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const items = (data && data.prioridades) ? data.prioridades : [];
          sel.innerHTML = '<option value="" disabled selected>Seleccione prioridad</option>' +
            items.map(x => `<option value="${x.id}">${x.nombre}</option>`).join('');
        }).catch(() => { sel.innerHTML = '<option value="">Error</option>'; });
    }
    document.addEventListener('DOMContentLoaded', () => {
      const form = document.getElementById('ticketForm');
      if (form) form.addEventListener('submit', submitTicket);
      const selAs = document.getElementById('selAsunto');
      if (selAs) selAs.addEventListener('change', onAsuntoChange);
      loadCategorias();
      loadPrioridades();
      loadMyTickets();
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
            const mine = MY_TICKET_IDS.has(x.id_ticket);
            return `<div class="${mine ? 'bg-amber-50' : ''} flex items-center justify-between py-3 rounded-lg px-3 -mx-3">
              <div>
                <div class="text-sm font-medium text-slate-900">${x.codigo || ('TK-' + String(x.id_ticket).padStart(6,'0'))} • ${x.asunto}</div>
                <div class="text-xs text-slate-500">${who}</div>
              </div>
              <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
            </div>`;
          }).join('');
        }).catch(() => {});
    });
  </script>
</body>
</html>
