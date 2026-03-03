/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.municocachacra.dao;

import com.municocachacra.model.Usuario;
import java.sql.SQLException;
import java.util.List;

public interface UsuarioDAO {

    Usuario obtenerPorEmail(String email) throws SQLException;

    Usuario iniciarSesion(String email, String password) throws SQLException;

    boolean registrar(Usuario u) throws SQLException;

    List<Usuario> listarTodos() throws SQLException;

    boolean actualizar(Usuario u) throws SQLException;

    boolean eliminar(int idUsuario) throws SQLException;
}
