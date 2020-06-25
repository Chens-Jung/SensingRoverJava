package com.mycompany.project.model;

public class Sensor {
	//필드
	private int gas;
	private int thermistor;
	private int photoresister;
	private int tracking;
	private double ultrasonic;
	public int getGas() {
		return gas;
	}
	public void setGas(int gas) {
		this.gas = gas;
	}
	public int getThermistor() {
		return thermistor;
	}
	public void setThermistor(int thermistor) {
		this.thermistor = thermistor;
	}
	public int getPhotoresister() {
		return photoresister;
	}
	public void setPhotoresister(int photoresister) {
		this.photoresister = photoresister;
	}
	public int getTracking() {
		return tracking;
	}
	public void setTracking(int tracking) {
		this.tracking = tracking;
	}
	public double getUltrasonic() {
		return ultrasonic;
	}
	public void setUltrasonic(double ultrasonic) {
		this.ultrasonic = ultrasonic;
	}
	
	
}
