package com.municocachacra.dao;

import com.municocachacra.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class InsumoDAOImpl {
  public boolean descontarStock(int idInsumo, int cantidad) throws SQLException {
    String sql = "UPDATE insumo SET stock_actual = stock_actual - ? WHERE id_insumo = ? AND stock_actual >= ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, cantidad);
      ps.setInt(2, idInsumo);
      ps.setInt(3, cantidad);
      return ps.executeUpdate() > 0;
    }
  }

  public boolean aumentarStock(int idInsumo, int cantidad) throws SQLException {
    String sql = "UPDATE insumo SET stock_actual = stock_actual + ? WHERE id_insumo = ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, cantidad);
      ps.setInt(2, idInsumo);
      return ps.executeUpdate() > 0;
    }
  }
}
