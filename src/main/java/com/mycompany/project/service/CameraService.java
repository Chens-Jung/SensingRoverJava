package com.mycompany.project.service;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mycompany.project.dao.CameraDao;
import com.mycompany.project.model.CaptureImage;


@Service
public class CameraService {
	private static final Logger LOGGER = LoggerFactory.getLogger(SensorService.class);

	@Autowired
	private CameraDao cameraDao;
	
	public void saveCaptureImage(CaptureImage captureImage) {
		cameraDao.insertCaptureImage(captureImage);
	}
	
	public List<CaptureImage> getAllImage() {
		return cameraDao.selectAll();
	}

	public CaptureImage getImage(int cno) {
		return cameraDao.selectCaptureImage(cno);
	}
}
