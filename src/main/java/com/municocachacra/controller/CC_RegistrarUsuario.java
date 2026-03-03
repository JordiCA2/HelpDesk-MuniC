package com.municocachacra.controller;

import java.io.IOException;
import java.io.PrintWriter;
import org.json.JSONArray;
import org.json.JSONObject;
import com.municocachacra.dao.UsuarioDAO;
import com.municocachacra.dao.UsuarioDAOImpl;
import com.municocachacra.dao.RolDAOImpl;
import com.municocachacra.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CC_RegistrarUsuario", urlPatterns = {"/seguridad/registrar","/seguridad/usuarios"})
public class CC_RegistrarUsuario extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String path = request.getServletPath();
    if ("/seguridad/usuarios".equals(path)) {
      jakarta.servlet.http.HttpSession s = request.getSession(false);
      Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
      if (rol == null || rol.intValue() != 1) {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        return;
      }
    }
    response.setContentType("application/json;charset=UTF-8");
    try {
      UsuarioDAO dao = new UsuarioDAOImpl();
      java.util.List<Usuario> lista = dao.listarTodos();
      JSONArray arr = new JSONArray();
      for (Usuario u : lista) {
        JSONObject item = new JSONObject();
        item.put("id_usuario", u.getIdUsuario());
        item.put("id_rol", u.getIdRol());
        item.put("dni", u.getDni());
        item.put("nombres", u.getNombres());
        item.put("apellidos", u.getApellidos());
        item.put("email", u.getEmail());
        arr.put(item);
      }
      JSONObject out = new JSONObject();
      out.put("usuarios", arr);
      try (PrintWriter w = response.getWriter()) { w.print(out.toString()); }
    } catch (Exception e) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }
  }
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    request.setCharacterEncoding("UTF-8");
    String path = request.getServletPath();
    if ("/seguridad/usuarios".equals(path)) {
      jakarta.servlet.http.HttpSession s = request.getSession(false);
      Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
      if (rol == null || rol.intValue() != 1) {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        return;
      }
    }
    String ct = request.getContentType();
    String dni = null, nombres = null, apellidos = null, email = null, password = null, confirm = null, accion = null;
    Integer idUsuario = null, idRolNuevo = null;
    JSONObject json = null;
    if (ct != null && ct.toLowerCase().contains("application/json")) {
      String body = request.getReader().lines().reduce("", (a,b) -> a + b);
      json = new JSONObject(body);
      accion = json.optString("accion", null);
      idUsuario = json.has("idUsuario") ? Integer.valueOf(json.optInt("idUsuario")) : null;
      idRolNuevo = json.has("idRol") ? Integer.valueOf(json.optInt("idRol")) : null;
      dni = json.optString("dni", null);
      nombres = json.optString("nombres", null);
      apellidos = json.optString("apellidos", null);
      email = json.optString("email", null);
      password = json.optString("password", null);
      confirm = json.optString("confirm", null);
    } else {
      accion = request.getParameter("accion");
      String idStr = request.getParameter("idUsuario");
      idUsuario = (idStr != null && !idStr.isBlank()) ? Integer.valueOf(idStr) : null;
      String idRolStr = request.getParameter("idRol");
      idRolNuevo = (idRolStr != null && !idRolStr.isBlank()) ? Integer.valueOf(idRolStr) : null;
      dni = request.getParameter("dni");
      nombres = request.getParameter("nombres");
      apellidos = request.getParameter("apellidos");
      email = request.getParameter("email");
      password = request.getParameter("password");
      confirm = request.getParameter("confirm");
    }
    if ("/seguridad/registrar".equals(path)) {
      if (dni == null || dni.isBlank()) dni = "00000000";
      idRolNuevo = 3;
    }
    if (accion != null && accion.equalsIgnoreCase("eliminar")) {
      try {
        UsuarioDAO dao = new UsuarioDAOImpl();
        boolean ok = (idUsuario != null) && dao.eliminar(idUsuario);
        response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
      } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      }
      return;
    }
    if (accion != null && accion.equalsIgnoreCase("actualizar")) {
      try {
        UsuarioDAO dao = new UsuarioDAOImpl();
        if (idUsuario == null) {
          response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
          return;
        }
        Usuario u = new Usuario();
        u.setIdUsuario(idUsuario);
        u.setIdRol(idRolNuevo != null ? idRolNuevo.intValue() : 3);
        u.setDni(dni != null ? dni : "");
        u.setNombres(nombres != null ? nombres : "");
        u.setApellidos(apellidos != null ? apellidos : "");
        u.setEmail(email != null ? email : "");
        u.setPassword(password != null ? password : "");
        boolean ok = dao.actualizar(u);
        response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
      } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      }
      return;
    }
    if (accion != null && accion.equalsIgnoreCase("crear")) {
      confirm = confirm != null ? confirm : password;
    }
    boolean invalid = (nombres == null || nombres.isBlank()
        || email == null || email.isBlank()
        || password == null || password.isBlank()
        || confirm == null || confirm.isBlank()
        || !password.equals(confirm));
    if (invalid) {
      if (ct != null && ct.toLowerCase().contains("application/json")) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=validation");
      }
      return;
    }
    try {
      UsuarioDAO dao = new UsuarioDAOImpl();
      Usuario existente = dao.obtenerPorEmail(email);
      if (existente != null) {
        if (ct != null && ct.toLowerCase().contains("application/json")) {
          response.setStatus(HttpServletResponse.SC_CONFLICT);
        } else {
          response.sendRedirect(request.getContextPath() + "/login.jsp?error=email");
        }
        return;
      }
      RolDAOImpl rolDao = new RolDAOImpl();
      int idRol = rolDao.obtenerIdPorNombre("Usuario");
      if (idRol == 0) {
        idRol = 3;
      }
      if (idRolNuevo != null) {
        idRol = idRolNuevo.intValue();
      }
      Usuario u = new Usuario();
      u.setIdRol(idRol);
      u.setDni(dni);
      u.setNombres(nombres);
      u.setApellidos(apellidos != null ? apellidos : "");
      u.setEmail(email);
      u.setPassword(password);
      boolean ok = dao.registrar(u);
      if (ct != null && ct.toLowerCase().contains("application/json")) {
        response.setStatus(ok ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_BAD_REQUEST);
      } else {
        if (ok) {
          response.sendRedirect(request.getContextPath() + "/login.jsp?success=1");
        } else {
          response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
        }
      }
    } catch (Exception e) {
      if (ct != null && ct.toLowerCase().contains("application/json")) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
      }
    }
  }
}
