package com.mycompany.project.dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;

@Repository
public class CameraDao extends EgovAbstractMapper {
	private static final Logger LOGGER = LoggerFactory.getLogger(CameraDao.class);
}
