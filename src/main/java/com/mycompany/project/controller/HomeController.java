package com.mycompany.project.controller;

import java.util.Calendar;
import java.util.TimeZone;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

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
	
	@RequestMapping("/exam04Data")
	public String exam04Data(Model model) {
		Calendar now = Calendar.getInstance();
		Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		cal.set(
			now.get(Calendar.YEAR), 
			now.get(Calendar.MONTH+1), 
			now.get(Calendar.DATE), 
			now.get(Calendar.HOUR_OF_DAY), 
			now.get(Calendar.MINUTE), 
			now.get(Calendar.SECOND)
		);
		long x = cal.getTimeInMillis();
		int y = (int)(Math.random()*100);
		model.addAttribute("x", x);
		model.addAttribute("y", y);
		return "exam04Data"; 
	}
}
