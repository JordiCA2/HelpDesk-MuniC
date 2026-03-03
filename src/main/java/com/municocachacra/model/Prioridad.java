package com.municocachacra.model;

public class Prioridad {

    private int idPrioridad;
    private String nivel;

    public Prioridad() {
    }

    public Prioridad(int idPrioridad, String nivel) {
        this.idPrioridad = idPrioridad;
        this.nivel = nivel;
    }

    public int getIdPrioridad() {
        return idPrioridad;
    }

    public void setIdPrioridad(int idPrioridad) {
        this.idPrioridad = idPrioridad;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }
}
