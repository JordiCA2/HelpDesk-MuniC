package com.municocachacra.model;

import java.sql.Timestamp;

public class Movimiento {

    private int idMovimiento;
    private int idInsumo;
    private Timestamp fecha;
    private String tipo;     // 'Entrada' o 'Salida'
    private int cantidad;

    public Movimiento() {
    }

    public Movimiento(int idMovimiento, int idInsumo, Timestamp fecha, String tipo, int cantidad) {
        this.idMovimiento = idMovimiento;
        this.idInsumo = idInsumo;
        this.fecha = fecha;
        this.tipo = tipo;
        this.cantidad = cantidad;
    }

    public int getIdMovimiento() {
        return idMovimiento;
    }

    public void setIdMovimiento(int idMovimiento) {
        this.idMovimiento = idMovimiento;
    }

    public int getIdInsumo() {
        return idInsumo;
    }

    public void setIdInsumo(int idInsumo) {
        this.idInsumo = idInsumo;
    }

    public java.sql.Timestamp getFecha() {
        return fecha;
    }

    public void setFecha(java.sql.Timestamp fecha) {
        this.fecha = fecha;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }
}
