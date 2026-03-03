package com.municocachacra.controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import com.municocachacra.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "CC_GestionarReportes", urlPatterns = {"/reportes/generar"})
public class CC_GestionarReportes extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CC_GestionarReportes</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CC_GestionarReportes at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        JSONObject out = new JSONObject();
        try (Connection cn = DatabaseUtil.getConnection()) {
            try (PreparedStatement ps = cn.prepareStatement("SELECT COUNT(*) AS c FROM ticket");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) out.put("tickets_total", rs.getInt("c"));
            }
            try (PreparedStatement ps = cn.prepareStatement("SELECT COUNT(*) AS c FROM ticket WHERE estado IS NULL OR estado NOT IN ('Resuelto','Finalizado','Cerrado')");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) out.put("tickets_abiertos", rs.getInt("c"));
            }
            try (PreparedStatement ps = cn.prepareStatement("SELECT COUNT(*) AS c FROM ticket WHERE estado IN ('Resuelto','Finalizado') AND DATE(fecha_registro) = CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) out.put("soportes_finalizados_hoy", rs.getInt("c"));
            }
            try (PreparedStatement ps = cn.prepareStatement("SELECT COUNT(*) AS c FROM insumo WHERE stock_actual <= stock_minimo");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) out.put("insumos_por_agotarse", rs.getInt("c"));
            }
            try (PreparedStatement ps = cn.prepareStatement("SELECT estado, COUNT(*) AS c FROM ticket GROUP BY estado");
                 ResultSet rs = ps.executeQuery()) {
                org.json.JSONArray estados = new org.json.JSONArray();
                while (rs.next()) {
                    JSONObject item = new JSONObject();
                    item.put("estado", rs.getString("estado"));
                    item.put("cantidad", rs.getInt("c"));
                    estados.put(item);
                }
                out.put("tickets_por_estado", estados);
            }
            try (PreparedStatement ps = cn.prepareStatement("SELECT t.id_ticket, t.asunto, t.estado, t.fecha_registro, u.nombres AS solicitante FROM ticket t LEFT JOIN usuario u ON t.id_solicitante = u.id_usuario ORDER BY t.fecha_registro DESC LIMIT 10");
                 ResultSet rs = ps.executeQuery()) {
                org.json.JSONArray ultimos = new org.json.JSONArray();
                while (rs.next()) {
                    JSONObject item = new JSONObject();
                    item.put("id_ticket", rs.getInt("id_ticket"));
                    item.put("asunto", rs.getString("asunto"));
                    item.put("estado", rs.getString("estado"));
                    item.put("fecha_registro", rs.getTimestamp("fecha_registro").toInstant().toString());
                    item.put("solicitante", rs.getString("solicitante"));
                    ultimos.put(item);
                }
                out.put("ultimos_tickets", ultimos);
            }
            try (PrintWriter w = response.getWriter()) { w.print(out.toString()); }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "CC_GestionarReportes";
    }
}
