package com.municocachacra.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import com.municocachacra.dao.TicketDAOImpl;
import com.municocachacra.model.Ticket;
import java.sql.Timestamp;
import com.municocachacra.util.DatabaseUtil;

@WebServlet(name = "CC_GestionarTicket", urlPatterns = {"/ticket/gestionar"})
public class CC_GestionarTicket extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CC_GestionarTicket</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CC_GestionarTicket at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String accion = request.getParameter("accion");
        if (accion == null || accion.isBlank()) accion = "listar";
        try (Connection cn = DatabaseUtil.getConnection()) {
            if ("listar".equalsIgnoreCase(accion)) {
                StringBuilder sql = new StringBuilder(
                    "SELECT t.id_ticket, t.asunto, t.estado, t.fecha_registro, " +
                    "u.nombres AS solicitante, te.nombres AS tecnico " +
                    "FROM ticket t " +
                    "LEFT JOIN usuario u ON t.id_solicitante = u.id_usuario " +
                    "LEFT JOIN usuario te ON t.id_tecnico = te.id_usuario " +
                    "WHERE 1=1 "
                );
                Integer solicitante = parseInt(request.getParameter("solicitante"));
                Integer tecnico = parseInt(request.getParameter("tecnico"));
                String estado = request.getParameter("estado");
                int paramIdx = 1;
                if (solicitante != null) sql.append("AND t.id_solicitante = ? ");
                if (tecnico != null) sql.append("AND t.id_tecnico = ? ");
                if (estado != null && !estado.isBlank()) sql.append("AND t.estado = ? ");
                sql.append("ORDER BY t.fecha_registro DESC");
                try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
                    if (solicitante != null) ps.setInt(paramIdx++, solicitante);
                    if (tecnico != null) ps.setInt(paramIdx++, tecnico);
                    if (estado != null && !estado.isBlank()) ps.setString(paramIdx++, estado);
                    try (ResultSet rs = ps.executeQuery();
                         PrintWriter w = response.getWriter()) {
                        org.json.JSONArray arr = new org.json.JSONArray();
                        while (rs.next()) {
                            int id = rs.getInt("id_ticket");
                            JSONObject item = new JSONObject();
                            item.put("id_ticket", id);
                            item.put("codigo", String.format("TK-%06d", id));
                            item.put("asunto", rs.getString("asunto"));
                            item.put("estado", rs.getString("estado"));
                            item.put("fecha_registro", rs.getTimestamp("fecha_registro").toInstant().toString());
                            item.put("solicitante", rs.getString("solicitante"));
                            item.put("tecnico", rs.getString("tecnico"));
                            arr.put(item);
                        }
                        JSONObject out = new JSONObject();
                        out.put("tickets", arr);
                        w.print(out.toString());
                    }
                }
            } else if ("listarReportes".equalsIgnoreCase(accion)) {
                Integer tecnico = parseInt(request.getParameter("tecnico"));
                String sql = "SELECT r.id_reporte, r.id_ticket, r.comentario, r.fecha, t.asunto, u.nombres AS tecnico " +
                             "FROM ticket_reporte r " +
                             "JOIN ticket t ON r.id_ticket = t.id_ticket " +
                             "LEFT JOIN usuario u ON r.id_tecnico = u.id_usuario ";
                if (tecnico != null) sql += "WHERE r.id_tecnico = ? ";
                sql += "ORDER BY r.fecha DESC";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    if (tecnico != null) ps.setInt(1, tecnico);
                    try (ResultSet rs = ps.executeQuery();
                         PrintWriter w = response.getWriter()) {
                        org.json.JSONArray arr = new org.json.JSONArray();
                        while (rs.next()) {
                            JSONObject item = new JSONObject();
                            item.put("id_reporte", rs.getInt("id_reporte"));
                            item.put("id_ticket", rs.getInt("id_ticket"));
                            item.put("asunto", rs.getString("asunto"));
                            item.put("comentario", rs.getString("comentario"));
                            item.put("fecha", rs.getTimestamp("fecha").toInstant().toString());
                            item.put("tecnico", rs.getString("tecnico"));
                            arr.put(item);
                        }
                        JSONObject out = new JSONObject();
                        out.put("reportes", arr);
                        w.print(out.toString());
                    }
                }
            } else if ("listarCategorias".equalsIgnoreCase(accion)) {
                String sql = "SELECT id_categoria, nombre FROM categoria ORDER BY nombre ASC";
                try (PreparedStatement ps = cn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery();
                     PrintWriter w = response.getWriter()) {
                    org.json.JSONArray arr = new org.json.JSONArray();
                    while (rs.next()) {
                        JSONObject item = new JSONObject();
                        item.put("id", rs.getInt("id_categoria"));
                        item.put("nombre", rs.getString("nombre"));
                        arr.put(item);
                    }
                    JSONObject out = new JSONObject();
                    out.put("categorias", arr);
                    w.print(out.toString());
                }
            } else if ("listarPrioridades".equalsIgnoreCase(accion)) {
                String sql = "SELECT MIN(id_prioridad) AS id_prioridad, TRIM(LOWER(nivel)) AS nivel_normalizado FROM prioridad GROUP BY TRIM(LOWER(nivel)) ORDER BY id_prioridad ASC";
                try (PreparedStatement ps = cn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery();
                     PrintWriter w = response.getWriter()) {
                    org.json.JSONArray arr = new org.json.JSONArray();
                    while (rs.next()) {
                        String n = rs.getString("nivel_normalizado");
                        String nombre = (n != null && !n.isEmpty()) ? n.substring(0,1).toUpperCase() + n.substring(1) : "";
                        JSONObject item = new JSONObject();
                        item.put("id", rs.getInt("id_prioridad"));
                        item.put("nombre", nombre);
                        arr.put(item);
                    }
                    JSONObject out = new JSONObject();
                    out.put("prioridades", arr);
                    w.print(out.toString());
                }
            } else if ("listarAsuntosPorCategoria".equalsIgnoreCase(accion)) {
                Integer idCat = parseInt(request.getParameter("idCategoria"));
                if (idCat == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                String sql = "SELECT DISTINCT asunto FROM ticket WHERE id_categoria = ? AND asunto IS NOT NULL AND asunto <> '' ORDER BY asunto ASC LIMIT 50";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    ps.setInt(1, idCat);
                    try (ResultSet rs = ps.executeQuery();
                         PrintWriter w = response.getWriter()) {
                        org.json.JSONArray arr = new org.json.JSONArray();
                        while (rs.next()) {
                            String as = rs.getString("asunto");
                            if (as != null && !as.isBlank()) {
                                JSONObject item = new JSONObject();
                                item.put("nombre", as);
                                arr.put(item);
                            }
                        }
                        if (arr.length() == 0) {
                            String[] defaults = new String[] {
                                "Problema de impresora",
                                "Problema de Internet",
                                "Instalación de software",
                                "Error de sistema",
                                "Consulta de cuenta de correo"
                            };
                            for (String d : defaults) {
                                JSONObject item = new JSONObject();
                                item.put("nombre", d);
                                arr.put(item);
                            }
                        }
                        JSONObject out = new JSONObject();
                        out.put("asuntos", arr);
                        w.print(out.toString());
                    }
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ct = request.getContentType();
        String accion = request.getParameter("accion");
        JSONObject json = null;
        if (ct != null && ct.toLowerCase().contains("application/json")) {
            String body = request.getReader().lines().reduce("", (a,b) -> a + b);
            json = new JSONObject(body);
            if (accion == null) accion = json.optString("accion", null);
        }

        if ("crear".equalsIgnoreCase(accion)) {
            int idSolicitante, idTecnico, idCategoria, idPrioridad;
            String asunto, descripcion, estado;
            if (json != null) {
                idSolicitante = json.optInt("idSolicitante");
                idTecnico = json.optInt("idTecnico", 0);
                idCategoria = json.optInt("idCategoria");
                idPrioridad = json.optInt("idPrioridad");
                asunto = json.optString("asunto", "");
                descripcion = json.optString("descripcion", "");
                estado = json.optString("estado", "Pendiente");
            } else {
                idSolicitante = Integer.parseInt(request.getParameter("idSolicitante"));
                idTecnico = Integer.parseInt(request.getParameter("idTecnico") == null ? "0" : request.getParameter("idTecnico"));
                idCategoria = Integer.parseInt(request.getParameter("idCategoria"));
                idPrioridad = Integer.parseInt(request.getParameter("idPrioridad"));
                asunto = request.getParameter("asunto");
                descripcion = request.getParameter("descripcion");
                estado = request.getParameter("estado") != null ? request.getParameter("estado") : "Pendiente";
            }
            Ticket t = new Ticket();
            t.setIdSolicitante(idSolicitante);
            t.setIdTecnico(idTecnico);
            t.setIdCategoria(idCategoria);
            t.setIdPrioridad(idPrioridad);
            t.setFechaRegistro(new Timestamp(System.currentTimeMillis()));
            t.setAsunto(asunto);
            t.setDescripcion(descripcion);
            t.setEstado(estado);
            try {
                boolean ok = new TicketDAOImpl().crearTicket(t);
                if (json != null) {
                    response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                } else {
                    response.sendRedirect(request.getContextPath() + (ok ? "/dashboard.html?ticket=ok" : "/dashboard.html?ticket=err"));
                }
            } catch (Exception e) {
                if (json != null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard.html?ticket=db");
                }
            }
        } else if ("cambiarEstado".equalsIgnoreCase(accion)) {
            int idTicket; String nuevoEstado;
            if (json != null) {
                idTicket = json.optInt("idTicket");
                nuevoEstado = json.optString("nuevoEstado", "Pendiente");
            } else {
                idTicket = Integer.parseInt(request.getParameter("idTicket"));
                nuevoEstado = request.getParameter("nuevoEstado");
            }
            try {
                boolean ok = new TicketDAOImpl().cambiarEstado(idTicket, nuevoEstado);
                response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else if ("atender".equalsIgnoreCase(accion)) {
            int idTicket;
            Integer idTecnico = null;
            if (json != null) {
                idTicket = json.optInt("idTicket");
            } else {
                idTicket = Integer.parseInt(request.getParameter("idTicket"));
            }
            jakarta.servlet.http.HttpSession s = request.getSession(false);
            if (s != null) {
                Object tid = s.getAttribute("usuarioId");
                if (tid instanceof Integer) idTecnico = (Integer) tid;
            }
            if (idTecnico == null) idTecnico = 0;
            try (Connection cn = DatabaseUtil.getConnection();
                 PreparedStatement ps = cn.prepareStatement("UPDATE ticket SET estado = ?, id_tecnico = ? WHERE id_ticket = ?")) {
                ps.setString(1, "En Atención");
                ps.setInt(2, idTecnico);
                ps.setInt(3, idTicket);
                boolean ok = ps.executeUpdate() > 0;
                response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else if ("finalizar".equalsIgnoreCase(accion)) {
            int idTicket;
            String comentario;
            Integer idTecnico = null;
            if (json != null) {
                idTicket = json.optInt("idTicket");
                comentario = json.optString("comentario", "");
            } else {
                idTicket = Integer.parseInt(request.getParameter("idTicket"));
                comentario = request.getParameter("comentario");
            }
            jakarta.servlet.http.HttpSession s = request.getSession(false);
            if (s != null) {
                Object tid = s.getAttribute("usuarioId");
                if (tid instanceof Integer) idTecnico = (Integer) tid;
            }
            if (idTecnico == null) {
                idTecnico = 0;
            }
            try (Connection cn = DatabaseUtil.getConnection()) {
                boolean ok;
                if (idTecnico != null && idTecnico > 0) {
                    try (PreparedStatement ps = cn.prepareStatement("UPDATE ticket SET estado = ?, id_tecnico = ? WHERE id_ticket = ?")) {
                        ps.setString(1, "Resuelto");
                        ps.setInt(2, idTecnico);
                        ps.setInt(3, idTicket);
                        ok = ps.executeUpdate() > 0;
                    }
                } else {
                    ok = new TicketDAOImpl().cambiarEstado(idTicket, "Resuelto");
                }
                if (!ok) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                boolean exists = false;
                try (PreparedStatement chk = cn.prepareStatement(
                    "SELECT COUNT(*) AS c FROM ticket_reporte WHERE id_ticket = ? AND id_tecnico = ? AND comentario = ? AND TIMESTAMPDIFF(SECOND, fecha, NOW()) <= 5")) {
                    chk.setInt(1, idTicket);
                    chk.setInt(2, idTecnico);
                    chk.setString(3, comentario != null ? comentario : "");
                    try (ResultSet rs = chk.executeQuery()) {
                        if (rs.next()) exists = rs.getInt("c") > 0;
                    }
                }
                if (!exists) {
                    try (PreparedStatement ps = cn.prepareStatement(
                        "INSERT INTO ticket_reporte (id_ticket, id_tecnico, comentario, fecha) VALUES (?, ?, ?, NOW())")) {
                        ps.setInt(1, idTicket);
                        ps.setInt(2, idTecnico);
                        ps.setString(3, comentario != null ? comentario : "");
                        ps.executeUpdate();
                    }
                }
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    @Override
    public String getServletInfo() {
        return "CC_GestionarTicket";
    }

    private Integer parseInt(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }
}
