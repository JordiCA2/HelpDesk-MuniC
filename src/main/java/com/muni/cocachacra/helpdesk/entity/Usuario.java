package com.muni.cocachacra.helpdesk.entity;

import java.time.OffsetDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "usuarios")
public class Usuario {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "nombre_completo", nullable = false, length = 150)
  private String nombreCompleto;

  @Column(name = "email", nullable = false, length = 150, unique = true)
  private String email;

  @Column(name = "password_hash", nullable = false, length = 255)
  private String passwordHash;

  @ManyToOne(optional = false)
  @JoinColumn(name = "rol_id", nullable = false)
  private Rol rol;

  @Column(name = "activo", nullable = false)
  private boolean activo;

  @Column(name = "creado_en", nullable = false, insertable = false, updatable = false)
  private OffsetDateTime creadoEn;

  public Usuario() {}

  public Integer getId() { return id; }
  public void setId(Integer id) { this.id = id; }
  public String getNombreCompleto() { return nombreCompleto; }
  public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }
  public String getEmail() { return email; }
  public void setEmail(String email) { this.email = email; }
  public String getPasswordHash() { return passwordHash; }
  public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
  public Rol getRol() { return rol; }
  public void setRol(Rol rol) { this.rol = rol; }
  public boolean isActivo() { return activo; }
  public void setActivo(boolean activo) { this.activo = activo; }
  public OffsetDateTime getCreadoEn() { return creadoEn; }
  public void setCreadoEn(OffsetDateTime creadoEn) { this.creadoEn = creadoEn; }
}