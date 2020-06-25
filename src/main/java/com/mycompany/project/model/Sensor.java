package com.mycompany.project.model;

public class Sensor {
	//필드
	private int no;
	private int gas;
	private double thermistor;
	private int photoresistor;
	private String tracking;
	private double ultrasonic;
	private String date;
	
	
	public int getNo() {
		return no;
	}
	public int getGas() {
		return gas;
	}
	public void setGas(int gas) {
		this.gas = gas;
	}
	public double getThermistor() {
		return thermistor;
	}
	public void setThermistor(double thermistor) {
		this.thermistor = thermistor;
	}
	public int getPhotoresistor() {
		return photoresistor;
	}
	public void setPhotoresistor(int photoresistor) {
		this.photoresistor = photoresistor;
	}
	public String getTracking() {
		return tracking;
	}
	public void setTracking(String tracking) {
		this.tracking = tracking;
	}
	public double getUltrasonic() {
		return ultrasonic;
	}
	public void setUltrasonic(double ultrasonic) {
		this.ultrasonic = ultrasonic;
	}
	public String getDate() {
		return date;
	}
	public void setDate(String date) {
		this.date = date;
	}
	
	
}
