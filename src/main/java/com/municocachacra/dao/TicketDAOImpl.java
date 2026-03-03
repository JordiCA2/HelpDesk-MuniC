/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.municocachacra.dao;

import com.municocachacra.model.Ticket;
import com.municocachacra.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class TicketDAOImpl {
  public boolean crearTicket(Ticket t) throws SQLException {
    String sql = "INSERT INTO ticket (id_solicitante, id_tecnico, id_categoria, id_prioridad, fecha_registro, asunto, descripcion, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, t.getIdSolicitante());
      if (t.getIdTecnico() == 0) {
        ps.setNull(2, java.sql.Types.INTEGER);
      } else {
        ps.setInt(2, t.getIdTecnico());
      }
      ps.setInt(3, t.getIdCategoria());
      ps.setInt(4, t.getIdPrioridad());
      ps.setTimestamp(5, t.getFechaRegistro());
      ps.setString(6, t.getAsunto());
      ps.setString(7, t.getDescripcion());
      ps.setString(8, t.getEstado());
      int rows = ps.executeUpdate();
      return rows > 0;
    }
  }

  public boolean cambiarEstado(int idTicket, String nuevoEstado) throws SQLException {
    String sql = "UPDATE ticket SET estado = ? WHERE id_ticket = ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setString(1, nuevoEstado);
      ps.setInt(2, idTicket);
      return ps.executeUpdate() > 0;
    }
  }

  public boolean asignarTecnico(int idTicket, int idTecnico) throws SQLException {
    String sql = "UPDATE ticket SET id_tecnico = ? WHERE id_ticket = ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, idTecnico);
      ps.setInt(2, idTicket);
      return ps.executeUpdate() > 0;
    }
  }
}
