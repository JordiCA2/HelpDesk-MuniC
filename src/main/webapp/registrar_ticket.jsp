<%-- 
    Document   : registrar_ticket
    Created on : 2 mar 2026, 5:31:08
    Author     : Haskell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Registrar Ticket — Sistema de Soporte</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="color-scheme" content="light">
</head>
<body class="min-h-screen bg-slate-50 text-slate-800 antialiased">
  <header class="bg-white shadow-sm">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-slate-900 font-semibold tracking-tight">Registrar Ticket</span>
      </div>
      <nav>
        <a href="index.html" class="text-slate-700 hover:text-slate-900">Inicio</a>
      </nav>
    </div>
  </header>
  <main class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
<%
  jakarta.servlet.http.HttpSession s = request.getSession(false);
  Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
  if (rol == null || rol.intValue() != 3) {
%>
    <div class="rounded-xl border border-amber-200 bg-amber-50 p-6 text-amber-800 shadow-sm">
      Solo los usuarios de área pueden registrar tickets. Use el panel para gestionar tickets.
    </div>
<%
  } else {
%>
    <form action="ticket/gestionar" method="POST" class="bg-white rounded-xl p-6 shadow ring-1 ring-slate-200 space-y-4">
      <input type="hidden" name="accion" value="crear">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label for="idSolicitante" class="block text-sm font-medium text-slate-700">ID Solicitante</label>
          <input id="idSolicitante" name="idSolicitante" type="number" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
        </div>
        <div>
          <label for="idTecnico" class="block text-sm font-medium text-slate-700">ID Técnico (opcional)</label>
          <input id="idTecnico" name="idTecnico" type="number" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600" placeholder="0">
        </div>
        <div>
          <label for="idCategoria" class="block text-sm font-medium text-slate-700">ID Categoría</label>
          <input id="idCategoria" name="idCategoria" type="number" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
        </div>
        <div>
          <label for="idPrioridad" class="block text-sm font-medium text-slate-700">ID Prioridad</label>
          <input id="idPrioridad" name="idPrioridad" type="number" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
        </div>
      </div>
      <div>
        <label for="asunto" class="block text-sm font-medium text-slate-700">Asunto</label>
        <input id="asunto" name="asunto" type="text" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
      </div>
      <div>
        <label for="descripcion" class="block text-sm font-medium text-slate-700">Descripción</label>
        <textarea id="descripcion" name="descripcion" rows="4" required class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600"></textarea>
      </div>
      <div>
        <label for="estado" class="block text-sm font-medium text-slate-700">Estado</label>
        <select id="estado" name="estado" class="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-blue-600 focus:ring-blue-600">
          <option value="Pendiente">Pendiente</option>
          <option value="En Proceso">En Proceso</option>
          <option value="Finalizado">Finalizado</option>
        </select>
      </div>
      <div class="flex items-center justify-end gap-3">
        <a href="index.html" class="inline-flex items-center rounded-md bg-slate-100 px-4 py-2 text-slate-700 hover:bg-slate-200">Cancelar</a>
        <button type="submit" class="inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">Registrar</button>
      </div>
    </form>
<%
  }
%>
  </main>
</body>
</html>

