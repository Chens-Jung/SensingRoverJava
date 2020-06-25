package com.mycompany.project.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.mycompany.project.dao.SensorDao;
import com.mycompany.project.model.Sensor;

@Service
public class SensorService {
	private static final Logger LOGGER = LoggerFactory.getLogger(SensorService.class);

	@Autowired
	private SensorDao sensorDao;
	
	public void save(Sensor sensor) {
		sensorDao.insert(sensor);
	}
	
}
