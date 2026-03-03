<%-- 
    Document   : inventario
    Created on : 2 mar 2026, 5:31:47
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestión de Inventario — Sistema de Soporte</title>
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
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-slate-900 font-semibold tracking-tight">Gestión de Insumos</span>
      </div>
      <nav>
        <a href="index.html" class="text-slate-700 hover:text-slate-900">Inicio</a>
        <a href="seguridad/logout" class="ml-3 inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold text-slate-900">Insumos</h2>
        <button id="openAddInsumo" class="inline-flex items-center rounded-md bg-blue-600 px-3 py-2 text-white hover:bg-blue-700">Agregar insumo</button>
      </div>
      <div id="insumosList" class="mt-4 divide-y divide-slate-100"></div>
    </section>
    <div id="addInsumoModal" class="fixed inset-0 hidden items-center justify-center bg-black/40 z-50">
      <div class="w-full max-w-lg rounded-xl bg-white p-6 shadow">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-slate-900">Agregar Insumo</h3>
          <button id="closeAddModal" class="rounded-md bg-slate-100 px-3 py-1 text-slate-700 hover:bg-slate-200">Cerrar</button>
        </div>
        <form id="addInsumoForm" class="mt-4 space-y-3">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block text-sm font-medium text-slate-700">Nombre</label>
              <input type="text" id="insNombre" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm" required>
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700">Código</label>
              <input type="text" id="insCodigo" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm" placeholder="Opcional">
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block text-sm font-medium text-slate-700">Proveedor</label>
              <select id="insProveedor" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm"></select>
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700">Stock mínimo</label>
              <input type="number" id="insStockMin" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm" min="0" value="0" required>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700">Stock actual</label>
            <input type="number" id="insStockAct" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm" min="0" value="0" required>
          </div>
          <div class="flex justify-end gap-2">
            <button type="button" id="cancelAdd" class="inline-flex items-center rounded-md bg-slate-100 px-4 py-2 text-slate-700 hover:bg-slate-200">Cancelar</button>
            <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">Guardar</button>
          </div>
        </form>
      </div>
    </div>
  </main>
  <script>
    function stateBadge(stock, min) {
      const isNum = typeof stock === 'number';
      if (isNum && stock <= 0) return { cls: 'bg-red-100 text-red-700', txt: 'Agotado' };
      const low = (isNum && typeof min === 'number') && stock <= min;
      return low ? { cls: 'bg-amber-100 text-amber-700', txt: 'Por agotarse' } : { cls: 'bg-emerald-100 text-emerald-700', txt: 'OK' };
    }
    function renderInsumos(items) {
      const cont = document.getElementById('insumosList');
      cont.innerHTML = items.map(x => {
        const bb = stateBadge(x.stock_actual, x.stock_minimo);
        const stockLabel = (typeof x.stock_actual === 'number' && x.stock_actual <= 0)
          ? '<span class="font-medium text-red-600">Agotado</span>'
          : `<span class="font-medium">${x.stock_actual}</span>`;
        return `<div class="py-3 flex items-center justify-between">
          <div class="space-y-0.5">
            <div class="text-sm font-medium text-slate-900">${x.nombre} <span class="text-xs text-slate-500">(${x.codigo || '—'})</span></div>
            <div class="text-xs text-slate-500">Proveedor: ${x.proveedor || '—'}</div>
            <div class="text-xs text-slate-500">Stock: ${stockLabel} • Mínimo: ${x.stock_minimo}</div>
          </div>
          <div class="flex items-center gap-2">
            <button class="decInsumo inline-flex items-center rounded-md bg-slate-100 px-2.5 py-1.5 text-slate-700 hover:bg-slate-200" data-id="${x.id_insumo}">-1</button>
            <button class="incInsumo inline-flex items-center rounded-md bg-emerald-600 px-2.5 py-1.5 text-white hover:bg-emerald-700" data-id="${x.id_insumo}">+1</button>
            <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${bb.cls}">${bb.txt}</span>
          </div>
        </div>`;
      }).join('');
    }
    function loadInsumos() {
      fetch('almacen/insumos', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => { renderInsumos((data && data.insumos) ? data.insumos : []); });
    }
    function adjustInsumo(id, delta) {
      const op = delta > 0 ? 'aumentar' : 'descontar';
      const payload = { op, idInsumo: id, cantidad: Math.abs(delta) };
      fetch('almacen/gestionar', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
        .then(r => { if (r.ok) loadInsumos(); });
    }
    function loadProveedores() {
      fetch('almacen/insumos?accion=proveedores', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => {
          const sel = document.getElementById('insProveedor');
          const items = (data && data.proveedores) ? data.proveedores : [];
          sel.innerHTML = items.map(p => `<option value="${p.id_proveedor}">${p.razon_social}</option>`).join('');
        });
    }
    function openAdd() {
      const m = document.getElementById('addInsumoModal');
      m.classList.remove('hidden'); m.classList.add('flex');
      loadProveedores();
    }
    function closeAdd() {
      const m = document.getElementById('addInsumoModal');
      m.classList.add('hidden'); m.classList.remove('flex');
    }
    function onAddSubmit(e) {
      e.preventDefault();
      const payload = {
        nombre: document.getElementById('insNombre').value,
        codigo: document.getElementById('insCodigo').value,
        idProveedor: parseInt(document.getElementById('insProveedor').value, 10),
        stockMinimo: parseInt(document.getElementById('insStockMin').value, 10),
        stockActual: parseInt(document.getElementById('insStockAct').value, 10)
      };
      fetch('almacen/insumos', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
        .then(r => {
          if (r.ok) {
            closeAdd();
            loadInsumos();
          }
        });
    }
    document.addEventListener('DOMContentLoaded', () => {
      loadInsumos();
      const btn = document.getElementById('openAddInsumo');
      if (btn) btn.addEventListener('click', openAdd);
      const closeBtn = document.getElementById('closeAddModal');
      if (closeBtn) closeBtn.addEventListener('click', closeAdd);
      const cancelBtn = document.getElementById('cancelAdd');
      if (cancelBtn) cancelBtn.addEventListener('click', closeAdd);
      const form = document.getElementById('addInsumoForm');
      if (form) form.addEventListener('submit', onAddSubmit);
      const list = document.getElementById('insumosList');
      if (list) list.addEventListener('click', (e) => {
        const dec = e.target.closest('button.decInsumo');
        const inc = e.target.closest('button.incInsumo');
        if (dec) adjustInsumo(parseInt(dec.getAttribute('data-id'), 10), -1);
        else if (inc) adjustInsumo(parseInt(inc.getAttribute('data-id'), 10), +1);
      });
    });
  </script>
</body>
</html>
