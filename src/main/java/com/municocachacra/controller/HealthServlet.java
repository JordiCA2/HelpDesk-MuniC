package com.municocachacra.controller;

import com.municocachacra.util.DatabaseUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class HealthServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("text/plain;charset=UTF-8");
    try (PrintWriter out = resp.getWriter();
         Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement("SELECT 1");
         ResultSet rs = ps.executeQuery()) {
      boolean ok = rs.next();
      int usuarios = -1;
      try (PreparedStatement ps2 = cn.prepareStatement("SELECT COUNT(*) AS c FROM usuario");
           ResultSet rs2 = ps2.executeQuery()) {
        if (rs2.next()) usuarios = rs2.getInt("c");
      } catch (Exception ignore) { }
      if (ok) {
        out.println("OK");
        out.println("usuarios=" + usuarios);
      } else {
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("ERROR: SELECT 1 no devolvió filas");
      }
    } catch (Exception e) {
      resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      try (PrintWriter out = resp.getWriter()) {
        out.println("ERROR: " + e.getClass().getSimpleName());
      }
    }
  }
}