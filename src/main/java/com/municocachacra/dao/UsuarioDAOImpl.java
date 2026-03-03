/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.municocachacra.dao;

import com.municocachacra.model.Usuario;
import com.municocachacra.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAOImpl implements UsuarioDAO {
  @Override
  public Usuario obtenerPorEmail(String email) throws SQLException {
    String sql = "SELECT id_usuario, id_rol, dni, nombres, apellidos, email, password AS password FROM usuario WHERE email = ? LIMIT 1";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          Usuario u = new Usuario();
          u.setIdUsuario(rs.getInt("id_usuario"));
          u.setIdRol(rs.getInt("id_rol"));
          u.setDni(rs.getString("dni"));
          u.setNombres(rs.getString("nombres"));
          u.setApellidos(rs.getString("apellidos"));
          u.setEmail(rs.getString("email"));
          u.setPassword(rs.getString("password"));
          return u;
        }
      }
    }
    return null;
  }

  public Usuario iniciarSesion(String email, String password) throws SQLException {
    String sql = "SELECT id_usuario, id_rol, dni, nombres, apellidos, email, password FROM usuario WHERE email = ? AND password = ? LIMIT 1";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setString(1, email);
      ps.setString(2, password);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          Usuario u = new Usuario();
          u.setIdUsuario(rs.getInt("id_usuario"));
          u.setIdRol(rs.getInt("id_rol"));
          u.setDni(rs.getString("dni"));
          u.setNombres(rs.getString("nombres"));
          u.setApellidos(rs.getString("apellidos"));
          u.setEmail(rs.getString("email"));
          u.setPassword(rs.getString("password"));
          return u;
        }
      }
    }
    return null;
  }

  @Override
  public boolean registrar(Usuario u) throws SQLException {
    String sql = "INSERT INTO usuario (id_rol, dni, nombres, apellidos, email, password) VALUES (?, ?, ?, ?, ?, ?)";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, u.getIdRol());
      ps.setString(2, u.getDni());
      ps.setString(3, u.getNombres());
      ps.setString(4, u.getApellidos());
      ps.setString(5, u.getEmail());
      ps.setString(6, u.getPassword());
      int rows = ps.executeUpdate();
      return rows > 0;
    }
  }

  @Override
  public List<Usuario> listarTodos() throws SQLException {
    String sql = "SELECT id_usuario, id_rol, dni, nombres, apellidos, email, password FROM usuario ORDER BY id_usuario ASC";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
      List<Usuario> list = new ArrayList<>();
      while (rs.next()) {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setIdRol(rs.getInt("id_rol"));
        u.setDni(rs.getString("dni"));
        u.setNombres(rs.getString("nombres"));
        u.setApellidos(rs.getString("apellidos"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        list.add(u);
      }
      return list;
    }
  }

  @Override
  public boolean actualizar(Usuario u) throws SQLException {
    boolean updatePassword = (u.getPassword() != null && !u.getPassword().isBlank());
    String sql = updatePassword
      ? "UPDATE usuario SET id_rol = ?, dni = ?, nombres = ?, apellidos = ?, email = ?, password = ? WHERE id_usuario = ?"
      : "UPDATE usuario SET id_rol = ?, dni = ?, nombres = ?, apellidos = ?, email = ? WHERE id_usuario = ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, u.getIdRol());
      ps.setString(2, u.getDni());
      ps.setString(3, u.getNombres());
      ps.setString(4, u.getApellidos());
      ps.setString(5, u.getEmail());
      if (updatePassword) {
        ps.setString(6, u.getPassword());
        ps.setInt(7, u.getIdUsuario());
      } else {
        ps.setInt(6, u.getIdUsuario());
      }
      int rows = ps.executeUpdate();
      return rows > 0;
    }
  }

  @Override
  public boolean eliminar(int idUsuario) throws SQLException {
    String sql = "DELETE FROM usuario WHERE id_usuario = ?";
    try (Connection cn = DatabaseUtil.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, idUsuario);
      int rows = ps.executeUpdate();
      return rows > 0;
    }
  }
}
