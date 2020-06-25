package com.mycompany.project.controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.apache.commons.net.util.Base64;

@Controller
@RequestMapping("/home")
public class HomeController {
	private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);
	
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
}
