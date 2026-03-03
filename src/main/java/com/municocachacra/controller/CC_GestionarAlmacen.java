package com.municocachacra.controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import com.municocachacra.dao.InsumoDAOImpl;

@WebServlet(name = "CC_GestionarAlmacen", urlPatterns = {"/almacen/gestionar","/almacen/insumos"})
public class CC_GestionarAlmacen extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CC_GestionarAlmacen</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CC_GestionarAlmacen at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/almacen/insumos".equals(path)) {
            jakarta.servlet.http.HttpSession s = request.getSession(false);
            Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
            if (rol == null || (rol.intValue() != 1 && rol.intValue() != 2)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            response.setContentType("application/json;charset=UTF-8");
            String accion = request.getParameter("accion");
            if (accion == null || accion.isBlank()) accion = "listar";
            try (java.sql.Connection cn = com.municocachacra.util.DatabaseUtil.getConnection()) {
                if ("proveedores".equalsIgnoreCase(accion)) {
                    try (java.sql.PreparedStatement ps = cn.prepareStatement("SELECT id_proveedor, razon_social FROM proveedor ORDER BY razon_social ASC");
                         java.sql.ResultSet rs = ps.executeQuery();
                         java.io.PrintWriter w = response.getWriter()) {
                        org.json.JSONArray arr = new org.json.JSONArray();
                        while (rs.next()) {
                            org.json.JSONObject item = new org.json.JSONObject();
                            item.put("id_proveedor", rs.getInt("id_proveedor"));
                            item.put("razon_social", rs.getString("razon_social"));
                            arr.put(item);
                        }
                        org.json.JSONObject out = new org.json.JSONObject();
                        out.put("proveedores", arr);
                        w.print(out.toString());
                    }
                    return;
                }
                try (java.sql.PreparedStatement ps = cn.prepareStatement(
                        "SELECT i.id_insumo, i.codigo, i.nombre, i.stock_actual, i.stock_minimo, p.razon_social AS proveedor " +
                        "FROM insumo i LEFT JOIN proveedor p ON i.id_proveedor = p.id_proveedor " +
                        "ORDER BY i.nombre ASC");
                     java.sql.ResultSet rs = ps.executeQuery();
                     java.io.PrintWriter w = response.getWriter()) {
                    org.json.JSONArray arr = new org.json.JSONArray();
                    while (rs.next()) {
                        org.json.JSONObject item = new org.json.JSONObject();
                        item.put("id_insumo", rs.getInt("id_insumo"));
                        item.put("codigo", rs.getString("codigo"));
                        item.put("nombre", rs.getString("nombre"));
                        item.put("stock_actual", rs.getInt("stock_actual"));
                        item.put("stock_minimo", rs.getInt("stock_minimo"));
                        item.put("proveedor", rs.getString("proveedor"));
                        arr.put(item);
                    }
                    org.json.JSONObject out = new org.json.JSONObject();
                    out.put("insumos", arr);
                    w.print(out.toString());
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            return;
        }
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        String ct = request.getContentType();
        if ("/almacen/insumos".equals(path)) {
            jakarta.servlet.http.HttpSession s = request.getSession(false);
            Integer rol = s != null ? (Integer) s.getAttribute("usuarioRolId") : null;
            if (rol == null || (rol.intValue() != 1 && rol.intValue() != 2)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            String codigo = null, nombre = null;
            Integer idProveedor = null, stockMinimo = null, stockActual = null;
            if (ct != null && ct.toLowerCase().contains("application/json")) {
                String body = request.getReader().lines().reduce("", (a,b) -> a + b);
                JSONObject json = new JSONObject(body);
                codigo = json.optString("codigo", null);
                nombre = json.optString("nombre", null);
                idProveedor = json.has("idProveedor") ? json.optInt("idProveedor") : null;
                stockMinimo = json.has("stockMinimo") ? json.optInt("stockMinimo") : null;
                stockActual = json.has("stockActual") ? json.optInt("stockActual") : null;
            } else {
                codigo = request.getParameter("codigo");
                nombre = request.getParameter("nombre");
                String p = request.getParameter("idProveedor");
                String sm = request.getParameter("stockMinimo");
                String sa = request.getParameter("stockActual");
                if (p != null && !p.isBlank()) idProveedor = Integer.parseInt(p);
                if (sm != null && !sm.isBlank()) stockMinimo = Integer.parseInt(sm);
                if (sa != null && !sa.isBlank()) stockActual = Integer.parseInt(sa);
            }
            boolean invalid = (nombre == null || nombre.isBlank()
                || idProveedor == null
                || stockMinimo == null || stockMinimo < 0
                || stockActual == null || stockActual < 0);
            if (invalid) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            try (java.sql.Connection cn = com.municocachacra.util.DatabaseUtil.getConnection();
                 java.sql.PreparedStatement ps = cn.prepareStatement(
                    "INSERT INTO insumo (id_proveedor, codigo, nombre, stock_actual, stock_minimo) VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, idProveedor);
                ps.setString(2, codigo != null ? codigo : "");
                ps.setString(3, nombre);
                ps.setInt(4, stockActual);
                ps.setInt(5, stockMinimo);
                int rows = ps.executeUpdate();
                response.setStatus(rows > 0 ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_BAD_REQUEST);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            return;
        }
        String op = request.getParameter("op");
        Integer idInsumo = null;
        Integer cantidad = null;
        if (ct != null && ct.toLowerCase().contains("application/json")) {
            String body = request.getReader().lines().reduce("", (a,b) -> a + b);
            JSONObject json = new JSONObject(body);
            op = json.optString("op", op != null ? op : "descontar");
            idInsumo = json.has("idInsumo") ? json.optInt("idInsumo") : null;
            cantidad = json.has("cantidad") ? json.optInt("cantidad") : null;
        } else {
            String idInsumoStr = request.getParameter("idInsumo");
            String cantidadStr = request.getParameter("cantidad");
            if (idInsumoStr != null && !idInsumoStr.isBlank()) idInsumo = Integer.parseInt(idInsumoStr);
            if (cantidadStr != null && !cantidadStr.isBlank()) cantidad = Integer.parseInt(cantidadStr);
        }
        if (idInsumo == null || cantidad == null || cantidad <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            boolean ok = "aumentar".equalsIgnoreCase(op)
                ? new InsumoDAOImpl().aumentarStock(idInsumo, cantidad)
                : new InsumoDAOImpl().descontarStock(idInsumo, cantidad);
            response.setStatus(ok ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public String getServletInfo() {
        return "CC_GestionarAlmacen";
    }
}
