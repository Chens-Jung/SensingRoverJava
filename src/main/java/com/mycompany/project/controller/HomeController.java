package com.mycompany.project.controller;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.mycompany.project.model.CaptureImage;
import com.mycompany.project.service.CameraService;

import org.apache.commons.net.util.Base64;

import com.mycompany.project.model.Sensor;
import com.mycompany.project.service.SensorService;

@Controller
@RequestMapping("/home")
public class HomeController {
	private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);
	
	@Autowired
	private CameraService cameraService;
	
	
	@Autowired
	private SensorService sensorService;
	
	@RequestMapping("/main.do")
	public String main() {
		LOGGER.info("실행");
		return "home/main";
	}
	
	@RequestMapping("/exam19_mqtt.do")
	public String exam19_mqtt() {
		LOGGER.info("실행");
		return "home/exam19_mqtt";
	}
	
	@RequestMapping("/dashboard.do")
	public String dashboard() {
		LOGGER.info("실행");
		return "home/dashboard";
	}
	
	@PostMapping("/captureDown.do")
	public void captureDown(@RequestParam("img") String b64_string,
							HttpServletResponse response,
							HttpServletRequest request) throws IOException {		
//		LOGGER.info("실행");
		Date date = new Date();
		String saveDir = "C:/MyWorkspace/semiproject/capture_image/";
		String fileName = "capture_" + date.getTime() + ".jpg";
		String dateString = new SimpleDateFormat("YYYY/MM/dd HH:mm:ss").format(date);
		byte[] binary = Base64.decodeBase64(b64_string);
		FileOutputStream fos = new FileOutputStream(saveDir+fileName);
		fos.write(binary, 0, binary.length);
		fos.close();
		
		CaptureImage captureImage = new CaptureImage();
		captureImage.setCcontenttype(request.getServletContext().getMimeType(fileName));
		captureImage.setCfilename(saveDir+fileName);
		captureImage.setCdate(dateString);
		
		cameraService.saveCaptureImage(captureImage);
		
		response.setContentType("application/json;charset=UTF-8");
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("result", "성공!");
		
		PrintWriter pw = response.getWriter();
		pw.write(jsonObject.toString());
		pw.flush();
		pw.close();
	}
	
	@RequestMapping("/capturedlist.do")
	public String capturedlist(Model model) {
		List<CaptureImage> capturedList = cameraService.getAllImage();
		model.addAttribute("capturedList", capturedList);
		return "camera/capturedlist";
	}
	
	@GetMapping("/imageDetail.do")
	public String imageDetail(int cno, Model model) {
		CaptureImage image = cameraService.getImage(cno);
		model.addAttribute("image", image);
		return "camera/imagedetail";
	}
	
	@GetMapping("/imagedownload.do")
	public void imagedownload(int cno, HttpServletRequest request, HttpServletResponse response) throws Exception {
		CaptureImage image = cameraService.getImage(cno);
		
		String filePath = image.getCfilename();
		
		// 파일의 형식
		response.setContentType(image.getCcontenttype());
		// Body에 파일 데이터 쓰기
		InputStream is = new FileInputStream(filePath);
		OutputStream os = response.getOutputStream();
		FileCopyUtils.copy(is, os);
		os.close();
		is.close();
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
