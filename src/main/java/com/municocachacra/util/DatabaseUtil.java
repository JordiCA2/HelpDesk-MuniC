/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.municocachacra.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseUtil { 
  private static final String URL = System.getenv().getOrDefault("HELPDESK_DB_URL", "jdbc:mysql://localhost:3306/helpdesk_cocachacra?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
  private static final String USER = System.getenv().getOrDefault("HELPDESK_DB_USER", "root");
  private static final String PASS = System.getenv().getOrDefault("HELPDESK_DB_PASSWORD", "");

  public static Connection getConnection() throws SQLException {
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException ignore) {}
    return DriverManager.getConnection(URL, USER, PASS);
  }
}
