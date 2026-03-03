package com.municocachacra.controller;

import java.io.IOException;
import java.io.PrintWriter;

import org.json.JSONObject;

import com.municocachacra.dao.UsuarioDAO;
import com.municocachacra.dao.UsuarioDAOImpl;
import com.municocachacra.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CC_GestionarSeguridad", urlPatterns = {"/seguridad/login","/seguridad/logout"})
public class CC_GestionarSeguridad extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CC_GestionarSeguridad</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CC_GestionarSeguridad at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/seguridad/logout".equals(path)) {
            jakarta.servlet.http.HttpSession s = request.getSession(false);
            if (s != null) {
                s.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ct = request.getContentType();
        String email = null, password = null;
        if (ct != null && ct.toLowerCase().contains("application/json")) {
            String body = request.getReader().lines().reduce("", (a,b) -> a + b);
            JSONObject json = new JSONObject(body);
            email = json.optString("email", null);
            password = json.optString("password", null);
        } else {
            email = request.getParameter("email");
            password = request.getParameter("password");
        }
        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            if (ct != null && ct.toLowerCase().contains("application/json")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
            }
            return;
        }
        try {
            UsuarioDAO dao = new UsuarioDAOImpl();
            Usuario u = dao.iniciarSesion(email, password);
            boolean ok = (u != null);
            if (ct != null && ct.toLowerCase().contains("application/json")) {
                response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                if (ok) {
                    jakarta.servlet.http.HttpSession s = request.getSession(true);
                    try { request.changeSessionId(); } catch (Throwable ignore) {}
                    s.setAttribute("usuarioEmail", email);
                    s.setAttribute("usuarioId", u.getIdUsuario());
                    s.setAttribute("usuarioRolId", u.getIdRol());
                    s.setAttribute("usuarioNombre", u.getNombres());
                    String dest = "/usuario.jsp";
                    int role = u.getIdRol();
                    if (role == 1) dest = "/admin.jsp";
                    else if (role == 2) dest = "/asistente.jsp";
                    response.sendRedirect(request.getContextPath() + dest);
                } else {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
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

    @Override
    public String getServletInfo() {
        return "CC_GestionarSeguridad";
    }
}
