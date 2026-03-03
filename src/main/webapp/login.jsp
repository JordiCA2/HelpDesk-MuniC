<%-- 
    Document   : registrar_ticket
    Created on : 2 mar 2026, 5:31:08
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ingresar — Sistema de Soporte e Inventario</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased flex items-center justify-center">
  <div class="max-w-md w-full p-6 bg-white rounded-xl shadow ring-1 ring-slate-200">
    <h1 class="text-xl font-semibold text-slate-900">Acceder al sistema</h1>
    <p id="loginMsg" class="mt-2 text-sm text-slate-600">Ingresa o crea tu cuenta.</p>
    <form id="loginForm" action="seguridad/login" method="POST" class="mt-4 space-y-4">
      <div>
        <label for="email" class="block text-sm font-medium text-slate-700">Correo</label>
        <input id="email" name="email" type="email" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600" placeholder="usuario@cocachacra.gob.pe">
      </div>
      <div>
        <label for="password" class="block text-sm font-medium text-slate-700">Contraseña</label>
        <input id="password" name="password" type="password" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600" placeholder="••••••••">
      </div>
      <div class="flex items-center justify-end gap-3">
        <a href="index.html" class="inline-flex items-center rounded-md bg-slate-100 px-4 py-2 text-slate-700 hover:bg-slate-200">Cancelar</a>
        <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">Ingresar</button>
      </div>
    </form>
    <div class="mt-6">
      <button id="toggleRegister" type="button" class="w-full inline-flex items-center justify-center rounded-md bg-slate-100 px-4 py-2 text-slate-700 hover:bg-slate-200">Crear nueva cuenta</button>
      <form id="registerForm" action="seguridad/registrar" method="POST" class="mt-4 space-y-4 hidden">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label for="nombres" class="block text-sm font-medium text-slate-700">Nombres</label>
            <input id="nombres" name="nombres" type="text" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
          </div>
          <div>
            <label for="apellidos" class="block text-sm font-medium text-slate-700">Apellidos (opcional)</label>
            <input id="apellidos" name="apellidos" type="text" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
          </div>
        </div>
        <div>
          <label for="emailReg" class="block text-sm font-medium text-slate-700">Correo</label>
          <input id="emailReg" name="email" type="email" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600" placeholder="usuario@cocachacra.gob.pe">
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label for="passwordReg" class="block text-sm font-medium text-slate-700">Contraseña</label>
            <input id="passwordReg" name="password" type="password" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
          </div>
          <div>
            <label for="confirm" class="block text-sm font-medium text-slate-700">Confirmar</label>
            <input id="confirm" name="confirm" type="password" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
          </div>
        </div>
        <div class="flex items-center justify-end gap-3">
          <button type="submit" class="inline-flex items-center rounded-md bg-emerald-600 px-4 py-2 text-white hover:bg-emerald-700">Registrar</button>
        </div>
      </form>
    </div>
  </div>
  <script>
    (function() {
      const p = new URLSearchParams(window.location.search);
      const msg = document.getElementById('loginMsg');
      if (!msg) return;
      if (p.get('success') === '1') {
        msg.textContent = 'Cuenta creada correctamente. Ya puedes iniciar sesión.';
        msg.className = 'mt-2 text-sm text-emerald-600';
      } else if (p.get('error') === '1') {
        msg.textContent = 'Credenciales inválidas. Intenta nuevamente.';
        msg.className = 'mt-2 text-sm text-red-600';
      } else if (p.get('error') === 'db') {
        msg.textContent = 'Error de conexión con la base de datos.';
        msg.className = 'mt-2 text-sm text-red-600';
      } else if (p.get('error') === 'email') {
        msg.textContent = 'El correo ya está registrado.';
        msg.className = 'mt-2 text-sm text-red-600';
      } else if (p.get('error') === 'validation') {
        msg.textContent = 'Completa todos los campos y confirma la contraseña.';
        msg.className = 'mt-2 text-sm text-red-600';
      }
      const toggle = document.getElementById('toggleRegister');
      const form = document.getElementById('registerForm');
      const login = document.getElementById('loginForm');
      if (toggle && form && login) {
        toggle.addEventListener('click', () => {
          const showingRegister = form.classList.contains('hidden');
          form.classList.toggle('hidden');      // mostrar/ocultar registro
          login.classList.toggle('hidden');     // ocultar/mostrar login
          toggle.textContent = showingRegister ? 'Volver al login' : 'Crear nueva cuenta';
          const msg = document.getElementById('loginMsg');
          if (msg) msg.textContent = showingRegister ? 'Completa el registro para crear tu cuenta.' : 'Ingresa o crea tu cuenta.';
        });
      }
    })();
  </script>
</body>
</html>
