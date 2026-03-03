<%-- 
    Document   : reportes
    Created on : 2 mar 2026, 5:36:32
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Reportes — Sistema de Soporte</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased">
  <header class="bg-white shadow-sm">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-slate-900 font-semibold tracking-tight">Reportes</span>
      </div>
      <nav>
        <a href="index.html" class="text-slate-700 hover:text-slate-900">Inicio</a>
      </nav>
    </div>
  </header>
  <main class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="rounded-lg bg-white p-4 shadow ring-1 ring-slate-200">
        <div class="text-sm text-slate-600">Tickets Totales</div>
        <div id="repTotalTickets" class="mt-1 text-3xl font-bold text-slate-900">—</div>
      </div>
      <div class="rounded-lg bg-white p-4 shadow ring-1 ring-slate-200">
        <div class="text-sm text-slate-600">Finalizados</div>
        <div id="repFinalizados" class="mt-1 text-3xl font-bold text-slate-900">—</div>
      </div>
      <div class="rounded-lg bg-white p-4 shadow ring-1 ring-slate-200">
        <div class="text-sm text-slate-600">En Proceso</div>
        <div id="repEnProceso" class="mt-1 text-3xl font-bold text-slate-900">—</div>
      </div>
    </div>
    <div class="mt-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm overflow-x-auto">
      <h2 class="text-lg font-semibold text-slate-900">Distribución por Estado</h2>
      <table class="mt-4 w-full text-left text-sm">
        <thead class="text-slate-600">
          <tr>
            <th class="py-2 pr-4">Estado</th>
            <th class="py-2">Cantidad</th>
          </tr>
        </thead>
        <tbody id="repTablaEstados" class="text-slate-800">
        </tbody>
      </table>
    </div>
    <div class="mt-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <h2 class="text-lg font-semibold text-slate-900">Reportes</h2>
      <div id="repLista" class="mt-4 divide-y divide-slate-100"></div>
    </div>
  </main>
  <script>
    async function cargarReportes() {
      try {
        const res = await fetch('reportes/generar', { headers: { 'Accept': 'application/json' }});
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const data = await res.json();
        const total = data.tickets_total || 0;
        const estadosArr = Array.isArray(data.tickets_por_estado) ? data.tickets_por_estado : [];
        let finalizados = 0, enProceso = 0;
        estadosArr.forEach(e => {
          const nombre = (e.estado || '').toLowerCase();
          if (nombre === 'resuelto' || nombre === 'finalizado' || nombre === 'cerrado') finalizados += (e.cantidad || 0);
          if (nombre.includes('atenci')) enProceso += (e.cantidad || 0);
        });
        document.getElementById('repTotalTickets').textContent = total;
        document.getElementById('repFinalizados').textContent = finalizados;
        document.getElementById('repEnProceso').textContent = enProceso;
        const tbody = document.getElementById('repTablaEstados');
        tbody.innerHTML = '';
        estadosArr.forEach(e => {
          const tr = document.createElement('tr');
          const tdE = document.createElement('td');
          const tdC = document.createElement('td');
          tdE.className = 'py-2 pr-4'; tdC.className = 'py-2';
          tdE.textContent = e.estado || '—';
          tdC.textContent = e.cantidad || 0;
          tr.appendChild(tdE); tr.appendChild(tdC);
          tbody.appendChild(tr);
        });
      } catch (err) {
        document.getElementById('repTablaEstados').innerHTML = '<tr><td colspan="2" class="py-2 text-red-600">No se pudo cargar el reporte.</td></tr>';
      }
    }
    async function cargarListaReportes() {
      try {
        const res = await fetch('ticket/gestionar?accion=listarReportes', { headers: { 'Accept': 'application/json' } });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const data = await res.json();
        const items = Array.isArray(data.reportes) ? data.reportes : [];
        const cont = document.getElementById('repLista');
        cont.innerHTML = items.map(x => {
          const id = (x && x.id_ticket != null) ? String(x.id_ticket) : '';
          const cod = (x && x.codigo) ? x.codigo : (id ? ('TK-' + id.padStart(6,'0')) : 'TK-??????');
          const asunto = (x && x.asunto) ? x.asunto : 'Sin asunto';
          const fecha = (x && x.fecha) ? x.fecha : '—';
          const tec = (x && x.tecnico) ? x.tecnico : '—';
          const comentario = (x && x.comentario) ? x.comentario : '';
          return `<div class="py-3">
            <div class="text-sm font-semibold text-slate-900">${cod}</div>
            <div class="text-xs text-slate-700">Asunto: ${asunto}</div>
            <div class="text-xs text-slate-500">Fecha: ${fecha} • Técnico: ${tec}</div>
            <div class="text-sm text-slate-700">Comentario: ${comentario}</div>
          </div>`;
        }).join('') || '<div class="py-2 text-slate-600">No hay reportes</div>';
      } catch (err) {
        const cont = document.getElementById('repLista');
        cont.innerHTML = '<div class="py-2 text-red-600">No se pudo cargar la lista de reportes.</div>';
      }
    }
    document.addEventListener('DOMContentLoaded', () => { cargarReportes(); cargarListaReportes(); });
  </script>
</body>
</html>
