package com.mycompany.project.controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.net.util.Base64;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.mycompany.project.model.Sensor;
import com.mycompany.project.service.SensorService;

@Controller
@RequestMapping("/home")
public class HomeController {
	private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);
	
	@Autowired
	private SensorService sensorService;
	
	@RequestMapping("/main.do")
	public String main() {
		LOGGER.info("실행");
		return "home/main";
	}
	
	@RequestMapping("/dashboard.do")
	public String dashboard() {
		LOGGER.info("실행");
		return "home/dashboard";
	}
	
	@PostMapping("/captureDown.do")
	public void captureDown(@RequestParam("img") String b64_string,
							HttpServletResponse response) throws IOException {		
//		LOGGER.info("실행");
		
		String saveDir = "C:/MyWorkspace/semiproject/capture_image/capture_" + new Date().getTime() + ".jpg";
		byte[] binary = Base64.decodeBase64(b64_string);
		FileOutputStream fos = new FileOutputStream(saveDir);
		fos.write(binary, 0, binary.length);
		fos.close();
		
		response.setContentType("application/json;charset=UTF-8");
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("result", "성공!");
		
		PrintWriter pw = response.getWriter();
		pw.write(jsonObject.toString());
		pw.flush();
		pw.close();
	}
	
	@PostMapping("/saveSensor.do")
	public void saveSensor(int gas, double thermistor, int photoresistor,
			int tracking, double ultrasonic, HttpServletResponse response) throws IOException
	{
		Sensor sensor = new Sensor();
		sensor.setGas(gas);
		sensor.setThermistor(thermistor);
		sensor.setPhotoresistor(photoresistor);
		sensor.setUltrasonic(ultrasonic);
		if(tracking == 1) { sensor.setTracking("black"); }
		else if (tracking == 0) { sensor.setTracking("white"); }
		
		Date date = new Date();
		String dateString = new SimpleDateFormat("YYYY/MM/dd HH:mm:ss").format(date);
		sensor.setDate(dateString);
		
		//service로 보내기
		sensorService.save(sensor);
		
		//응답
		String result = "ok";
		response.setContentType("application/json; charset=UTF-8");
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("result", result);
		String json = jsonObject.toString();
		PrintWriter pw = response.getWriter();
		pw.write(json);
		pw.flush();
		pw.close();
	}
}
