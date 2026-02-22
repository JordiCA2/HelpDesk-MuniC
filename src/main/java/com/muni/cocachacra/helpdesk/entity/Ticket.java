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
@Table(name = "tickets")
public class Ticket {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "titulo", nullable = false, length = 180)
  private String titulo;

  @Column(name = "descripcion", nullable = false, columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "estado", nullable = false, length = 20)
  private String estado;

  @Column(name = "prioridad", nullable = false, length = 20)
  private String prioridad;

  @Column(name = "creado_en", nullable = false, insertable = false, updatable = false)
  private OffsetDateTime creadoEn;

  @ManyToOne(optional = false)
  @JoinColumn(name = "usuario_id", nullable = false)
  private Usuario usuario;

  @ManyToOne
  @JoinColumn(name = "tecnico_id")
  private Usuario tecnico;

  public Ticket() {}

  public Integer getId() { return id; }
  public void setId(Integer id) { this.id = id; }
  public String getTitulo() { return titulo; }
  public void setTitulo(String titulo) { this.titulo = titulo; }
  public String getDescripcion() { return descripcion; }
  public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
  public String getPrioridad() { return prioridad; }
  public void setPrioridad(String prioridad) { this.prioridad = prioridad; }
  public OffsetDateTime getCreadoEn() { return creadoEn; }
  public void setCreadoEn(OffsetDateTime creadoEn) { this.creadoEn = creadoEn; }
  public Usuario getUsuario() { return usuario; }
  public void setUsuario(Usuario usuario) { this.usuario = usuario; }
  public Usuario getTecnico() { return tecnico; }
  public void setTecnico(Usuario tecnico) { this.tecnico = tecnico; }
}