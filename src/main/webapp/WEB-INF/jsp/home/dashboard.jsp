<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Insert title here</title>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/bootstrap/css/bootstrap.min.css">
		<script src="${pageContext.request.contextPath}/resource/jquery/jquery.min.js"></script>
		<script src="${pageContext.request.contextPath}/resource/popper/popper.min.js"></script>
		<script src="${pageContext.request.contextPath}/resource/bootstrap/js/bootstrap.min.js"></script>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/jquery-ui/jquery-ui.min.css">
		<script src="${pageContext.request.contextPath}/resource/jquery-ui/jquery-ui.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.min.js" type="text/javascript"></script>
		
		<script src="http://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js"></script>
		
		<script src="https://code.highcharts.com/highcharts.js"></script>
		<script src="https://code.highcharts.com/highcharts-more.js"></script>
		<script src="https://code.highcharts.com/modules/solid-gauge.js"></script>
		<script src="https://code.highcharts.com/modules/exporting.js"></script>
		<script src="https://code.highcharts.com/modules/export-data.js"></script>
		<script src="https://code.highcharts.com/modules/accessibility.js"></script>
		
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/css/chartcss.css"/>
		<script src="<%=application.getContextPath()%>/resource/themes/dark-unica.js"></script>
		
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/css/style.css"/>

		<script type="text/javascript" src="${pageContext.request.contextPath}/resource/js/sensor_control.js" ></script> 
		
		<style>
			body {
				background: #384051;
			}
			p, h3, h6, font {
				color: #E4E5E7;
			}
		</style>
		
		
	</head>
	<body class="has-sidebar has-fixed-sidebar-and-header">
		<div class="container-fluid">
			<div class="row">
				<!-- ******** 카메라 뷰 ********* -->
				<div class="col-sm-9">
					<div class="row">
						<div class="col-sm-4" align="center">
							<img id="cameraView" style="width: 100%; height: 85%;"/><br/>
							<button class="btn btn-info" style="margin-top: 5px;" onclick="camera_capture()">capture</button>
							<a href="" style="margin-top: 5px;" class="btn btn-info">captured list</a>
						</div>
						
						<!-- ******** 카메라 제어 ********* -->
						<div class="col-sm-4">
				        	<div id="motor_control" align="center" style="padding:20px;">
								<p style="text-align: center"><font size="4">카메라 제어</font></p>
								<a id="cameraup" class="btn btn-info btn-lg" onmousedown="camera_button_down('up')" onmouseup="camera_button_up()" onclick="click_w()"
								style="margin-bottom:5px">W</a><br/>
								<a id="cameraleft" class="btn btn-info btn-lg" onmousedown="camera_button_down('left')" onmouseup="camera_button_up()" onclick="click_a()">A</a>
								<a id="cameradown" class="btn btn-info btn-lg" onmousedown="camera_button_down('down')" onmouseup="camera_button_up()" onclick="click_s()">S</a>
								<a id="cameraright" class="btn btn-info btn-lg" onmousedown="camera_button_down('right')" onmouseup="camera_button_up()" onclick="click_d()">D</a>
								<br/><br/>
								<p style="text-align: center"><font size="4">거리센서</font></p>
								<a id="sonicleft" class="btn btn-danger btn-lg" onmousedown="sonic_button_down('left')" onmouseup="sonic_button_up()" onclick="click_4()">4</a>
								<a id="sonicright" class="btn btn-danger btn-lg" onmousedown="sonic_button_down('right')" onmouseup="sonic_button_up()" onclick="click_6()">6</a>
							</div>
						</div>
						
						<div class="col-sm-4" id="section2_2" style="padding:3%;">
							<!-- ******** ON/OFF 제어 ********* -->
							<div id="rgbLed" align="center">
								<h3><font size="4">RGB LED</font></h3>
								<h6 id="rgbLed_state">rgbLed_state : </h6>
								<button class="btn btn-danger" onclick="rgbLed_red()">RED</button>
								<button class="btn btn-success" onclick="rgbLed_green()">GREEN</button>
								<button class="btn btn-primary" onclick="rgbLed_blue()">BLUE</button>
								<button class="btn btn-info" onclick="rgbLed_off()">OFF</button>
							</div>
							<div class="row" align="center">
					        	<div class="col-sm-6" id="buzzer">
									<h3 style="margin-top:10px"><font size="4">Buzzer</font></h3>
									<h6 id="buzzer_state">buzzer_state : </h6>
									<button class="btn btn-warning" onclick="buzzer_on()">ON</button>
									<button class="btn btn-info" onclick="buzzer_off()">OFF</button>
								</div>
					        	<div class="col-sm-6" id="laser" align="center">
									<h3 style="margin-top:10px"><font size="4">Laser</font></h3>
									<h6 id="laser_state">laser_state : </h6>
									<button class="btn btn-warning" onclick="laser_on()">ON</button>
									<button class="btn btn-info" onclick="laser_off()">OFF</button>
								</div>
							</div>
						</div>
					</div>
					
					<div class="row">
						<!-- ******** 속도 게이지 ********* -->
						<div class="col-sm-4">
							<figure class="highcharts-figure" >
								<div id="container-speed" class="chart-container" id="gage"></div>
								<p class="highcharts-description"><font size="4">속도</font></p>
							</figure>
						</div>
						
						<!-- ******** 타이어 컨트롤 ********* -->
						<div class="col-sm-4" id="section2_3" style="border-right:1px solid black" align="center">
							<p style="text-align: center"><font size="4">Tire Control</font></p>
							<div id="motor_control">
								<a class="btn btn-warning btn-lg" id="up" onmousedown="tire_button_down('up')" onmouseup="tire_button_up('up')" onclick="click_up()"
								style="margin-bottom: 5px;">↑</a><br/>
								<a class="btn btn-warning btn-lg" id="left" onmousedown="tire_button_down('left')" onmouseup="tire_button_up('left')" onclick="click_left()">←</a>
								<a class="btn btn-warning btn-lg" id="down" onmousedown="tire_button_down('down')" onmouseup="tire_button_up('down')" onclick="click_down()">↓</a>
								<a class="btn btn-warning btn-lg" id="right" onmousedown="tire_button_down('right')" onmouseup="tire_button_up('right')" onclick="click_right()">→</a>
								<p style="text-align: center"><font size="3" id="backTire_state">현재 상태: </font></p>
								<button class="btn btn-warning btn-lg" onclick="backTire_control('forward')">전진</button>
								<button class="btn btn-warning btn-lg" onclick="backTire_control('stop')">정지</button>
								<button class="btn btn-warning btn-lg" onclick="backTire_control('backward')">후진</button><br/><br/>
								<c:forEach var="i" begin="1" end="8">
									<button class="btn btn-warning btn" style="margin-bottom:3px"onclick="backTire_control('0', '${i}')">${i}</button>
									<c:if test="${i==4}"><br/></c:if>
								</c:forEach>
							</div><br/>
						</div>
						
						<!-- ******** LCD ********* -->
						<div class="col-sm-4" style="padding:20px;">
							<br/><br/>
							<div id="lcd" align="center">
								<h3>LCD</h3>
								<p id="lcd_state"><br/></p>
								<p style="display:inline-block;">lcd0:</p><input type="text" id="lcd0" size="25"/><br/>
								<p style="display:inline-block;">lcd1:</p><input type="text" id="lcd1" size="25"/><br/>
								<a onclick="lcd_write()" class="btn btn-success">보내기</a>
							</div>
							<br/><br/>
						</div>
				    </div>
				    
					<!-- ******** 차트 ********* -->
				    <div class="row" id="section3_1">
					  <div class="col-sm-4" id="gas" style="padding:20px"><figure class="highcharts-figure"></figure></div>
					  <div class="col-sm-4" id="thermistor" style="padding:20px"><figure class="highcharts-figure"></figure></div>
					  <div class="col-sm-4" id="photoresister" style="padding:20px"><figure class="highcharts-figure"></figure></div>
			        </div>
				</div>
				
				<div class="col-sm-3" align="center" style="border:1px solid black; height:930px">
					<div id="ultrasonic" style="height:35%; padding:10px; padding-top:45px;"><figure class="highcharts-figure"></figure></div>
					<div id="tracking" style="height:35%; padding:10px;"><figure class="highcharts-figure"></figure></div>
					<div>
						<a class="btn btn-danger btn-lg" onclick="dataSave()" style="height:30%; margin:26%">데이터 저장</a>
					</div>
		  		</div>
			</div>
		</div>
		
		<script type="text/javascript" src="${pageContext.request.contextPath}/resource/js/create_chart.js" ></script> 
	</body>

</html>