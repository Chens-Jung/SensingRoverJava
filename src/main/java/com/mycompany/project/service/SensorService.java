package com.mycompany.project.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mycompany.project.dao.SensorDao;
import com.mycompany.project.model.Sensor;

@Service
public class SensorService {

	@Autowired
	private SensorDao sensorDao;
	
	public void save(Sensor sensor) {
		sensorDao.insert(sensor);
	}
	
}
