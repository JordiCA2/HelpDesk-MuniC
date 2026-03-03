package com.municocachacra.model;

import java.sql.Timestamp;

public class Ticket {

    private int idTicket;
    private int idSolicitante;
    private int idTecnico;
    private int idCategoria;
    private int idPrioridad;
    private Timestamp fechaRegistro;
    private String asunto;
    private String descripcion;
    private String estado; // Valores esperados: 'Pendiente','En Atención','Resuelto','Cerrado'

    public Ticket() {
    }

    public Ticket(int idTicket, int idSolicitante, int idTecnico, int idCategoria, int idPrioridad, Timestamp fechaRegistro, String asunto, String descripcion, String estado) {
        this.idTicket = idTicket;
        this.idSolicitante = idSolicitante;
        this.idTecnico = idTecnico;
        this.idCategoria = idCategoria;
        this.idPrioridad = idPrioridad;
        this.fechaRegistro = fechaRegistro;
        this.asunto = asunto;
        this.descripcion = descripcion;
        this.estado = estado;
    }

    public int getIdTicket() {
        return idTicket;
    }

    public void setIdTicket(int idTicket) {
        this.idTicket = idTicket;
    }

    public int getIdSolicitante() {
        return idSolicitante;
    }

    public void setIdSolicitante(int idSolicitante) {
        this.idSolicitante = idSolicitante;
    }

    public int getIdTecnico() {
        return idTecnico;
    }

    public void setIdTecnico(int idTecnico) {
        this.idTecnico = idTecnico;
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }

    public int getIdPrioridad() {
        return idPrioridad;
    }

    public void setIdPrioridad(int idPrioridad) {
        this.idPrioridad = idPrioridad;
    }

    public java.sql.Timestamp getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(java.sql.Timestamp fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
