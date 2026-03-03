/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.municocachacra.dao;

import com.municocachacra.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RolDAOImpl {
  public int obtenerIdPorNombre(String nombre) throws SQLException {
    String sql = "SELECT id_rol FROM rol WHERE nombre = ? LIMIT 1";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setString(1, nombre);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getInt("id_rol");
        }
      }
    }
    return 0;
  }
}
