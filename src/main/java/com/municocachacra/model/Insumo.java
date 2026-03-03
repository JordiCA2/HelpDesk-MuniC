package com.municocachacra.model;

public class Insumo {

    private int idInsumo;
    private int idProveedor;
    private String codigo;
    private String nombre;
    private int stockActual;
    private int stockMinimo;

    public Insumo() {
    }

    public Insumo(int idInsumo, int idProveedor, String codigo, String nombre, int stockActual, int stockMinimo) {
        this.idInsumo = idInsumo;
        this.idProveedor = idProveedor;
        this.codigo = codigo;
        this.nombre = nombre;
        this.stockActual = stockActual;
        this.stockMinimo = stockMinimo;
    }

    public int getIdInsumo() {
        return idInsumo;
    }

    public void setIdInsumo(int idInsumo) {
        this.idInsumo = idInsumo;
    }

    public int getIdProveedor() {
        return idProveedor;
    }

    public void setIdProveedor(int idProveedor) {
        this.idProveedor = idProveedor;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getStockActual() {
        return stockActual;
    }

    public void setStockActual(int stockActual) {
        this.stockActual = stockActual;
    }

    public int getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(int stockMinimo) {
        this.stockMinimo = stockMinimo;
    }
}
