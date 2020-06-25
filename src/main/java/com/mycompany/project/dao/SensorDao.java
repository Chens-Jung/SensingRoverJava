package com.mycompany.project.dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;

@Repository
public class SensorDao extends EgovAbstractMapper {
	private static final Logger LOGGER = LoggerFactory.getLogger(SensorDao.class);
}
