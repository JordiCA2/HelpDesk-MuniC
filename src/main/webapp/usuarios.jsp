<%-- 
    Document   : usuarios
    Created on : 2 mar 2026, 5:36:53
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestión de Usuarios — Sistema de Soporte e Inventario</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
  <style>input,select{padding:.5rem}</style>
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
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-slate-900 font-semibold tracking-tight">Gestión de Usuarios</span>
      </div>
      <nav class="hidden sm:flex items-center gap-2">
        <a href="admin.jsp" class="inline-flex items-center rounded-md border border-slate-300 px-3 py-2 text-slate-700 hover:bg-slate-50">Panel Admin</a>
        <a href="index.html" class="inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-white hover:bg-red-700">Cerrar sesión</a>
      </nav>
    </div>
  </header>
  <main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <section class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-slate-900">Lista de Usuarios</h2>
          <button id="refreshUsers" class="text-sm text-blue-600 hover:underline">Actualizar lista</button>
        </div>
        <div id="usersList" class="mt-4 divide-y divide-slate-100"></div>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h2 class="text-lg font-semibold text-slate-900">Agregar Usuario</h2>
        <form id="userCreateForm" class="mt-4 space-y-3">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="text" name="nombres" placeholder="Área/Nombres" class="block w-full rounded-md border-slate-300 shadow-sm" required>
            <input type="text" name="apellidos" placeholder="Apellidos" class="block w-full rounded-md border-slate-300 shadow-sm" required>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="text" name="dni" placeholder="DNI" class="block w-full rounded-md border-slate-300 shadow-sm">
            <input type="email" name="email" placeholder="Correo" class="block w-full rounded-md border-slate-300 shadow-sm" required>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="password" name="password" placeholder="Contraseña" class="block w-full rounded-md border-slate-300 shadow-sm" required>
            <select name="idRol" class="block w-full rounded-md border-slate-300 shadow-sm">
              <option value="3">Usuario</option>
              <option value="2">Asistente</option>
              <option value="1">ADMIN</option>
            </select>
          </div>
          <div class="flex justify-end">
            <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">Agregar</button>
          </div>
        </form>
      </div>
    </section>
    <div id="editUserModal" class="fixed inset-0 hidden items-center justify-center bg-black/40 z-50">
      <div class="w-full max-w-lg rounded-xl bg-white p-6 shadow">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-slate-900">Editar Usuario</h3>
          <button id="closeEditModal" class="rounded-md bg-slate-100 px-3 py-1 text-slate-700 hover:bg-slate-200">Cerrar</button>
        </div>
        <form id="userEditForm" class="mt-4 space-y-3">
          <input type="hidden" id="editId">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="text" id="editNombres" placeholder="Área/Nombres" class="block w-full rounded-md border-slate-300 shadow-sm" required>
            <input type="text" id="editApellidos" placeholder="Apellidos" class="block w-full rounded-md border-slate-300 shadow-sm" required>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="text" id="editDni" placeholder="DNI" class="block w-full rounded-md border-slate-300 shadow-sm">
            <input type="email" id="editEmail" placeholder="Correo" class="block w-full rounded-md border-slate-300 shadow-sm" required>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <select id="editRol" class="block w-full rounded-md border-slate-300 shadow-sm">
              <option value="3">Usuario</option>
              <option value="2">Asistente</option>
              <option value="1">ADMIN</option>
            </select>
            <input type="password" id="editPassword" placeholder="Nueva contraseña (opcional)" class="block w-full rounded-md border-slate-300 shadow-sm">
          </div>
          <div class="flex justify-end gap-2">
            <button type="button" id="cancelEdit" class="inline-flex items-center rounded-md bg-slate-100 px-4 py-2 text-slate-700 hover:bg-slate-200">Cancelar</button>
            <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">Guardar</button>
          </div>
        </form>
      </div>
    </div>
  </main>
  <script>
    let USERS_CACHE = [];
    function renderUsers(items) {
      const cont = document.getElementById('usersList');
      USERS_CACHE = items.slice();
      cont.innerHTML = items.map(x => {
        const rol = x.id_rol === 1 ? 'ADMIN' : (x.id_rol === 2 ? 'Asistente' : 'Usuario');
        return `<div class="py-3 flex items-center justify-between">
          <div class="space-y-0.5">
            <div class="text-sm font-medium text-slate-900">${x.nombres} ${x.apellidos || ''}</div>
            <div class="text-xs text-slate-500">${x.email} • Rol: ${rol}</div>
          </div>
          <div class="flex items-center gap-2">
            <button class="inline-flex items-center rounded-md bg-slate-100 px-2 py-1 text-slate-700 hover:bg-slate-200" data-action="edit" data-id="${x.id_usuario}">Editar</button>
            <button class="inline-flex items-center rounded-md bg-red-600 px-2 py-1 text-white hover:bg-red-700" data-action="del" data-id="${x.id_usuario}">Eliminar</button>
          </div>
        </div>`;
      }).join('');
    }
    function loadUsers() {
      fetch('seguridad/usuarios', { headers: { 'Accept': 'application/json' } })
        .then(r => r.ok ? r.json() : null)
        .then(data => { const items = (data && data.usuarios) ? data.usuarios : []; renderUsers(items); });
    }
    function onUsersClick(e) {
      const btn = e.target.closest('button');
      if (!btn) return;
      const act = btn.getAttribute('data-action');
      const id = parseInt(btn.getAttribute('data-id'), 10);
      if (act === 'del') {
        fetch('seguridad/usuarios', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ accion: 'eliminar', idUsuario: id })
        }).then(r => { if (r.ok) loadUsers(); });
      } else if (act === 'edit') {
        const u = USERS_CACHE.find(x => x.id_usuario === id);
        if (!u) return;
        document.getElementById('editId').value = String(u.id_usuario);
        document.getElementById('editNombres').value = u.nombres || '';
        document.getElementById('editApellidos').value = u.apellidos || '';
        document.getElementById('editEmail').value = u.email || '';
        document.getElementById('editDni').value = u.dni || '';
        document.getElementById('editRol').value = String(u.id_rol || 3);
        document.getElementById('editPassword').value = '';
        const modal = document.getElementById('editUserModal');
        modal.classList.remove('hidden');
        modal.classList.add('flex');
      }
    }
    function onUserCreateSubmit(e) {
      e.preventDefault();
      const f = document.getElementById('userCreateForm');
      const payload = {
        accion: 'crear',
        nombres: f.nombres.value,
        apellidos: f.apellidos.value,
        dni: f.dni.value,
        email: f.email.value,
        password: f.password.value,
        confirm: f.password.value,
        idRol: parseInt(f.idRol.value, 10)
      };
      fetch('seguridad/usuarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).then(r => { if (r.ok) { f.reset(); loadUsers(); } });
    }
    function onUserEditSubmit(e) {
      e.preventDefault();
      const id = parseInt(document.getElementById('editId').value, 10);
      const payload = {
        accion: 'actualizar',
        idUsuario: id,
        idRol: parseInt(document.getElementById('editRol').value, 10),
        nombres: document.getElementById('editNombres').value,
        apellidos: document.getElementById('editApellidos').value,
        email: document.getElementById('editEmail').value,
        dni: document.getElementById('editDni').value
      };
      const pwd = document.getElementById('editPassword').value.trim();
      if (pwd.length > 0) payload.password = pwd;
      fetch('seguridad/usuarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).then(r => {
        if (r.ok) {
          const modal = document.getElementById('editUserModal');
          modal.classList.add('hidden');
          modal.classList.remove('flex');
          loadUsers();
        }
      });
    }
    function closeEdit() {
      const modal = document.getElementById('editUserModal');
      modal.classList.add('hidden');
      modal.classList.remove('flex');
    }
    document.addEventListener('DOMContentLoaded', () => {
      loadUsers();
      const btn = document.getElementById('refreshUsers');
      if (btn) btn.addEventListener('click', loadUsers);
      const list = document.getElementById('usersList');
      if (list) list.addEventListener('click', onUsersClick);
      const form = document.getElementById('userCreateForm');
      if (form) form.addEventListener('submit', onUserCreateSubmit);
      const editForm = document.getElementById('userEditForm');
      if (editForm) editForm.addEventListener('submit', onUserEditSubmit);
      const closeBtn = document.getElementById('closeEditModal');
      if (closeBtn) closeBtn.addEventListener('click', closeEdit);
      const cancelBtn = document.getElementById('cancelEdit');
      if (cancelBtn) cancelBtn.addEventListener('click', closeEdit);
    });
  </script>
</body>
</html>
