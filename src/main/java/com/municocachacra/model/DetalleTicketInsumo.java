package com.municocachacra.model;

public class DetalleTicketInsumo {

    private int idTicket;
    private int idInsumo;
    private int cantidad;

    public DetalleTicketInsumo() {
    }

    public DetalleTicketInsumo(int idTicket, int idInsumo, int cantidad) {
        this.idTicket = idTicket;
        this.idInsumo = idInsumo;
        this.cantidad = cantidad;
    }

    public int getIdTicket() {
        return idTicket;
    }

    public void setIdTicket(int idTicket) {
        this.idTicket = idTicket;
    }

    public int getIdInsumo() {
        return idInsumo;
    }

    public void setIdInsumo(int idInsumo) {
        this.idInsumo = idInsumo;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }
}
