package com.mycompany.project.dao;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import com.mycompany.project.model.CaptureImage;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;

@Repository
public class CameraDao extends EgovAbstractMapper {
	private static final Logger LOGGER = LoggerFactory.getLogger(CameraDao.class);

	public void insertCaptureImage(CaptureImage captureImage) {
		insert("insertCaptureImage", captureImage);
	}
	
	public List<CaptureImage> selectAll() {
		return selectList("selectAll");
	}

	public CaptureImage selectCaptureImage(int cno) {
		return selectOne("selectCaptureImage", cno);
	}
}
