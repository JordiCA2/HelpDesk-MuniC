package com.muni.cocachacra.helpdesk.entity;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "insumos")
public class Insumo {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "nombre", nullable = false, length = 120)
  private String nombre;

  @Column(name = "descripcion", length = 255)
  private String descripcion;

  @Column(name = "stock", nullable = false)
  private Integer stock;

  @Column(name = "costo", precision = 12, scale = 2)
  private BigDecimal costo;

  @Column(name = "creado_en", nullable = false, insertable = false, updatable = false)
  private OffsetDateTime creadoEn;

  public Insumo() {}

  public Integer getId() { return id; }
  public void setId(Integer id) { this.id = id; }
  public String getNombre() { return nombre; }
  public void setNombre(String nombre) { this.nombre = nombre; }
  public String getDescripcion() { return descripcion; }
  public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
  public Integer getStock() { return stock; }
  public void setStock(Integer stock) { this.stock = stock; }
  public BigDecimal getCosto() { return costo; }
  public void setCosto(BigDecimal costo) { this.costo = costo; }
  public OffsetDateTime getCreadoEn() { return creadoEn; }
  public void setCreadoEn(OffsetDateTime creadoEn) { this.creadoEn = creadoEn; }
}