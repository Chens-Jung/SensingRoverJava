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
		
		<style>
			body {
				background: #384051;
			}
			p, h3, h6, font {
				color: #E4E5E7;
			}
		</style>
		
		<script>
			var data = {
					gas:0,
					photoresistor:0,
					thermistor:0,
					ultrasonic:0,
					tracking:0,
					dcMotor_speed:0
			};
			var jsonMessage = {};
			var pwm = 0;

			/* var data;
			var jsonMessage; */
			$(function(){
				// location.hostname : IP(WAS와 MQTT가 같은 곳에서 실행되고 있어야 같은 IP로 쓸 수 있다.)
				client = new Paho.MQTT.Client(location.hostname, 61614, new Date().getTime().toString());
				
				//메시지 도착하면 실행할 콜백함수 지정
				client.onMessageArrived = onMessageArrived;
				
				//연결, 콜백함수 지정
				client.connect({onSuccess:onConnect});
			});
			
			function onConnect() {
				console.log("mqtt broker connected");
				client.subscribe("/camerapub");
				client.subscribe("/sensor");
				client.subscribe("/capturepub");
			}
	
			function onMessageArrived(message) {
				/* console.log("실행");
				console.log(message.payloadString); */
				if(message.destinationName == "/capturepub") {
					var b64_data = message.payloadString;
// 					var b64_object = {
// 							img: b64_data
// 					};
					$.ajax({
						type:"POST",
						url:"captureDown.do",
						data:{img:b64_data},
						success:function(data) {
							window.alert("캡처파일 저장 " + data.result);
						}
					});
					console.log("ajax");
				}
				if(message.destinationName == "/camerapub") {
					var cameraView = $("#cameraView").attr("src", "data:image/jpg;base64," + message.payloadString);
				}
				if(message.destinationName == "/pwm") {
					pwm = parseInt(message.payloadString);
					console.log(pwm);
				}
				if(message.destinationName == "/sensor") {
					
					//console.log(message.payloadString)
// 					document.getElementById("p").innerHTML = message.payloadString;
					var jsonObject = JSON.parse(message.payloadString);
					document.getElementById("laser_state").innerHTML = "laser_state : " + jsonObject["laseremmiter_state"];
					document.getElementById("buzzer_state").innerHTML = "buzzer_state : " + jsonObject["buzzer_state"];
					document.getElementById("backTire_state").innerHTML = "현재상태 : " + jsonObject["dcMotor_state"];
					document.getElementById("rgbLed_state").innerHTML = "rgbLed_state : " + jsonObject["rgbLed_state"];
					document.getElementById("lcd_state").innerHTML = "현재 출력 : " + jsonObject["lcd_state"];
						

					data = jsonObject;
					// console.log(data.dcMotor_speed);
					document.getElementById("backTire_state").innerHTML = "현재상태 : " + jsonObject["dcMotor_state"];
				
					//차트 설정================================================================================
					var x = (new Date()).getTime();
					//console.log("x:", x);

					var y1 = data.gas;
					var point1 = [x, y1]
					var series = chart1.series[0];
					var shift = series.data.length > 20;
					chart1.series[0].addPoint(point1, true, shift);

					var y2 = parseInt(data.thermistor);
					var point2 = [x, y2]
					var series = chart2.series[0];
					var shift = series.data.length > 20;
					chart2.series[0].addPoint(point2, true, shift);
					
					var y3 = data.photoresistor;
					var point3 = [x, y3]
					var series = chart3.series[0];
					var shift = series.data.length > 20;
					chart3.series[0].addPoint(point3, true, shift);
					
					var y4 = data.ultrasonic;
					var point4 = [x, y4]
					var series = chart4.series[0];
					var shift = series.data.length > 20;
					chart4.series[0].addPoint(point4, true, shift);
					
					var y5 = data.tracking;
					var point5 = [x, y5]
					var series = chart5.series[0];
					var shift = series.data.length > 20;
					chart5.series[0].addPoint(point5, true, shift);
					//차트 설정================================================================================
					
					if(data.ultrasonic < 10){
						buzzer_on();
						setTimeout(buzzer_off, 300);
					}
				}
				
			}
			function lcd_write() {
				var lcd0c = $("#lcd0").val()
				var lcd1c = $("#lcd1").val()
				var target = {
						lcd0:lcd0c,
						lcd1:lcd1c
				};
				
				asd = new Paho.MQTT.Message(JSON.stringify(target));
			    message.destinationName = "command/lcd";
			    client.send(message);
			}
			function laser_on() {
				message = new Paho.MQTT.Message("on")
				message.destinationName = "command/laser/on";
				client.send(message);
			}
			
			function laser_off() {
				message = new Paho.MQTT.Message("off")
				message.destinationName = "command/laser/off";
				client.send(message);
			
			}
			function buzzer_on() {
				message = new Paho.MQTT.Message("on")
				message.destinationName = "command/buzzer/on";
				client.send(message);
			}
			
			function buzzer_off() {
				message = new Paho.MQTT.Message("off")
				message.destinationName = "command/buzzer/off";
				client.send(message);
			}

			var speed = 0;
			var order = "stop";
			var stopped = false;
			function backTire_control(setOrder, setSpeed) {
				var message = 0;
				if(setSpeed != undefined) {
					speed = setSpeed;
				}
				if(stopped == true) {
					speed = 0;
					stopped = false;
				}
				if(setOrder != '0') {
					order = setOrder;
				}
				if(order == "stop") {
					speed = 0;
				}
				
				var target = {
						direction:order,
						pwm:speed
				};
				
				message = new Paho.MQTT.Message(JSON.stringify(target));
				message.destinationName = "command/backTire/button";
				client.send(message);
			}
			
			function rgbLed_red(){
				console.log("rgbRED");
				message = new Paho.MQTT.Message("red")
				message.destinationName = "command/rgbLed/red";
				client.send(message);
			}
			
			function rgbLed_green(){
				message = new Paho.MQTT.Message("green")
				message.destinationName = "command/rgbLed/green";
				client.send(message);
			}
			
			function rgbLed_blue(){
				message = new Paho.MQTT.Message("blue")
				message.destinationName = "command/rgbLed/blue";
				client.send(message);
			}
			
			function rgbLed_off(){
				message = new Paho.MQTT.Message("off")
				message.destinationName = "command/rgbLed/off";
				client.send(message);
			}
			
			var isPressed = false;
			
			document.onkeydown = onkeydown_handler;
			document.onkeyup = onkeyup_handler;
			
			function onkeydown_handler(event) {
				var keycode = event.which || event.keycode;
				console.log(keycode);
				if(keycode == 87 || keycode== 65 || keycode== 83 || keycode== 68){		//카메라 제어
					if(keycode == 83){					//앞
						$("#cameradown").css("background-color", "green");
						var topic="command/camera/front";
					} else if(keycode == 65){			//왼쪽
						$("#cameraleft").css("background-color", "green");
						console.log(keycode);
						var topic="command/camera/left";
					} else if(keycode == 87){			//뒤
						$("#cameraup").css("background-color", "green");
						var topic="command/camera/back";
					} else if(keycode == 68){			//오른쪽
						$("#cameraright").css("background-color", "green");
						var topic="command/camera/right";
					}
					message = new Paho.MQTT.Message("camera");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 37 || keycode == 39) {
					if(keycode == 37) {
						//left
						$("#left").css("background-color", "green");
						var topic = "command/frontTire/left";
						console.log(topic);
					}else if(keycode == 39) {
						//right
						$("#right").css("background-color", "green");
						topic = "command/frontTire/right";
						console.log(topic);
					}
					message = new Paho.MQTT.Message("frontTire");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 38 || keycode == 40 || keycode == 32) {
					if(keycode == 38) {
						// up
						$("#up").css("background-color", "green");
						var topic = "command/backTire/forward";
					} else if(keycode == 40) {
						// down
						$("#down").css("background-color", "green");
						var topic = "command/backTire/backward";
					} else if(keycode == 32) {
						//spacebar
						stopped = true;
						var topic = "command/backTire/stop";
					}
					message = new Paho.MQTT.Message("backTire");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 100 || keycode == 102) {		// 거리 센서 제어
					if(keycode == 100) {					//좌
						$("#sonicleft").css("background-color", "green");
						var topic = "command/distance/left";
					} else if(keycode == 102) {				//우
						$("#sonicright").css("background-color", "green");
						var topic = "command/distance/right";
					} 
					message = new Paho.MQTT.Message("distance");
					message.destinationName = topic;
					client.send(message);
				}
			}
			
			function onkeyup_handler(event) {
				var keycode = event.which || event.keycode;
				if(keycode == 37 || keycode == 39) {
					$("#left").css("background-color", "");
					$("#right").css("background-color", "");
					var topic = "command/frontTire/front";
					message = new Paho.MQTT.Message("frontTire");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 38 || keycode == 40) {
					$("#up").css("background-color", "");
					$("#down").css("background-color", "");
					var topic = "command/backTire/respeed";
					message = new Paho.MQTT.Message("backTire");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 87 || keycode== 65 || keycode== 83 || keycode== 68) {
					$("#cameraup").css("background-color", "");
					$("#cameradown").css("background-color", "");
					$("#cameraright").css("background-color", "");
					$("#cameraleft").css("background-color", "");
				}
				if(keycode == 100 || keycode == 102) {
					$("#sonicleft").css("background-color", "");
					$("#sonicright").css("background-color", "");
				}
			}
			
			var backbuttonPressed = false;
			var frontbuttonPressed = false;
			function tire_button_down(direction) {
				if(direction=="up" || direction=="down") {
					backbuttonPressed = true;
				}
				else {
					frontbuttonPressed = true;
				}
				
				tire_control(direction);
				
			}
			
			function tire_button_up(direction) {
				if(direction=="up" || direction=="down") {
					backbuttonPressed = false;
					var topic = "command/backTire/respeed";
					message = new Paho.MQTT.Message("backTire");
					message.destinationName = topic;
					client.send(message);
				} else {
					frontbuttonPressed = false;
					var topic = "command/frontTire/front";
					message = new Paho.MQTT.Message("frontTire");
					message.destinationName = topic;
					client.send(message);
				}
			}
			
			function tire_control(direction) {
				if(backbuttonPressed) {
					if(direction == 'up') {
						var topic = "command/backTire/forward";
					}else if(direction == 'down') {
						var topic = "command/backTire/backward";
					}
					message = new Paho.MQTT.Message("tire");
					message.destinationName = topic;
					client.send(message);
					
					setTimeout(function() {
						tire_control(direction);
					}, 30);
				}
				if(frontbuttonPressed) {
					if(direction == 'left') {
						var topic = "command/frontTire/left";
					}else if(direction == 'right') {
						var topic = "command/frontTire/right";
					}
					message = new Paho.MQTT.Message("tire");
					message.destinationName = topic;
					client.send(message);
					
					setTimeout(function() {
						tire_control(direction);
					}, 30);
				}
			}
			
			
			$(function() {
				var directions = document.querySelectorAll("#tire_control a");
				directions.forEach(function(a) {
					console.log(a.id);
					a.addEventListener("touchstart", function() {
						go = true;
						tire_control_touch(a.id);
					});
					a.addEventListener("touchend", function() {
						go = false;
					});
				});
			})
			
			var go = false;
			function tire_control_touch(direction) {
				if(go) {
					if(direction == "up") {
						var topic = "command/backTire/forward";
					}
					if(direction == "down") {
						var topic = "command/backTire/backward";
					}
					if(direction == "left") {
						var topic = "command/frontTire/left";
					}
					if(direction == "right") {
						var topic = "command/frontTire/right";
					}
					message = new Paho.MQTT.Message("tire");
					message.destinationName = topic;
					client.send(message);
					setTimeout(function() {
						tire_control_touch(direction);
					}, 30);
				}else {
					if(direction == "up" || direction == "down") {
						var topic = "command/backTire/respeed";
						message = new Paho.MQTT.Message("tire");
						message.destinationName = topic;
						client.send(message);	
					}else {
						var topic = "command/frontTire/front";
						message = new Paho.MQTT.Message("tire");
						message.destinationName = topic;
						client.send(message);	
					}
					
				}	
			}
				
			
			$(function() {
				var motor_direction = document.querySelectorAll("#motor_control a");
				motor_direction.forEach(function(a) {
					a.addEventListener("touchstart", function() {
						move = true;
						camera_control_touch(a.id);
					});
					a.addEventListener("touchend", function() {
						move = false;
					});
				});
				
				
			});
			var move = false;
			function camera_control_touch(motor_direction){
				if(move){
					if(motor_direction == 'cameraup') {
						var topic="command/camera/back";
					}if(motor_direction == 'cameradown') {
						var topic="command/camera/front";
					}if(motor_direction == 'cameraleft') {
						var topic="command/camera/left";
					}if(motor_direction == 'cameraright') {
						var topic="command/camera/right";
					}if(motor_direction == 'sonicleft') {
						var topic="command/distance/left";
					}if(motor_direction == 'sonicright') {
						var topic="command/distance/right";
					}
					message = new Paho.MQTT.Message("camera&sonic");
					message.destinationName = topic;
					client.send(message);
					setTimeout(function() {
						camera_control_touch(motor_direction);
					}, 30);
				}
			}
			
			var camerabuttonPressed = false;
			function camera_button_down(direction) {
				camerabuttonPressed = true;
				camera_control(direction);
			}
			function camera_button_up() {
				camerabuttonPressed = false;
			}
			
			
			
			
			function camera_control(direction) {
				if(camerabuttonPressed) {
					if(direction == 'up') {
						var topic="command/camera/back";
					}else if(direction == 'down') {
						var topic="command/camera/front";
					}else if(direction == 'left') {
						var topic="command/camera/left";
					}else if(direction == 'right') {
						var topic="command/camera/right";
					}
					message = new Paho.MQTT.Message("camera");
					message.destinationName = topic;
					client.send(message);
					setTimeout(function() {
						camera_control(direction);
					}, 30);
				}
			}
			
			var sonicbuttonPressed = false;
			function sonic_button_down(direction) {
				console.log('keydown');
				sonicbuttonPressed = true;
				sonic_control(direction);
			}
			function sonic_button_up() {
				console.log('keyup');
				sonicbuttonPressed = false;
			}
			function sonic_control(direction) {
				if(sonicbuttonPressed) {
					if(direction == 'left') {
						var topic = "command/distance/left"; 
					}else if(direction == 'right') {
						var topic = "command/distance/right";
					}
					message = new Paho.MQTT.Message("distance");
					message.destinationName = topic;
					client.send(message);
					setTimeout(function() {
						sonic_control(direction);
					}, 30);
				}
			}
			
			
			
			function click_w() {
			  console.log("클릭 w 실행됨");
			  message = new Paho.MQTT.Message("click_w")
			  message.destinationName = "command/camera/back";
			  client.send(message);
			}
			function click_a() {
			  console.log("클릭 a 실행됨");
			  message = new Paho.MQTT.Message("click_a")
			  message.destinationName = "command/camera/left";
			  client.send(message);
			}
			function click_d() {
			  message = new Paho.MQTT.Message("click_d")
			  message.destinationName = "command/camera/right";
			  client.send(message);
			}
			function click_s() {
			  message = new Paho.MQTT.Message("click_s")
			  message.destinationName = "command/camera/front";
			  client.send(message);
			}

			function click_up() {
			  message = new Paho.MQTT.Message("click_s")
			  message.destinationName = "command/backTire/forward";
			  client.send(message);
			}
			function click_down() {
			  message = new Paho.MQTT.Message("click_s")
			  message.destinationName = "command/backTire/backward";
			  client.send(message);
			}
			function click_left() {
			  message = new Paho.MQTT.Message("click_left")
			  message.destinationName = "command/frontTire/left";
			  client.send(message);
			}
			function click_right() {
			  message = new Paho.MQTT.Message("click_right")
			  message.destinationName = "command/frontTire/right";
			  client.send(message);
			}

			function click_4() {
			  message = new Paho.MQTT.Message("click_s")
			  message.destinationName = "command/distance/left";
			  client.send(message);
			}
			function click_6() {
			  message = new Paho.MQTT.Message("click_s")
			  message.destinationName = "command/distance/right";
			  client.send(message);
			}
			
			function camera_capture() {
				message = new Paho.MQTT.Message("capture")
				message.destinationName = "command/camera/capture";
				client.send(message);
			}
			
			//게이지----------------
			
			$(function(){var gaugeOptions = {
			  chart: {
			    type: 'solidgauge',
			    height:240,
			    width:320
			  },
			
			  title: null,
			
			  pane: {
			    center: ['50%', '55%'],
			    size: '100%',
			    startAngle: -90,
			    endAngle: 90,
			    background: {
			      backgroundColor:
			        Highcharts.defaultOptions.legend.backgroundColor || '#EEE',
			      innerRadius: '60%',
			      outerRadius: '100%',
			      shape: 'arc'
			    }
			  },
			
			  exporting: {
			    enabled: false
			  },
			
			  tooltip: {
			    enabled: false
			  },
			
			  // the value axis
			  yAxis: {
			    stops: [
			      [0.1, '#55BF3B'], // green
			      [0.5, '#DDDF0D'], // yellow
			      [0.9, '#DF5353'] // red
			    ],
			    lineWidth: 0,
			    tickWidth: 0,
			    minorTickInterval: null,
			    tickAmount: 2,
			    title: {
			      y: -70
			    },
			    labels: {
			      y: 16
			    }
			  },
			
			  plotOptions: {
			    solidgauge: {
			      dataLabels: {
			        y: 5,
			        borderWidth: 0,
			        useHTML: true
			      }
			    }
			  }
			};
			
			// The speed gauge
			var chartSpeed = Highcharts.chart('container-speed', Highcharts.merge(gaugeOptions, {
			  yAxis: {
			    min: 0,
			    max: 4000,
			    title: {
			      text: 'Speed'
			    }
			  },
			
			  credits: {
			    enabled: false
			  },
			
			  series: [{
			    name: 'Speed',
			    data: [0],
			    dataLabels: {
			      format:
			        '<div style="text-align:center">' +
			        '<span style="font-size:25px">{y}</span><br/>' +
			        '<span style="font-size:12px;opacity:0.4">km/h</span>' +
			        '</div>'
			    },
			    tooltip: {
			      valueSuffix: ' km/h'
			    }
			  }]
			
			}));
			
			// Bring life to the dials
			setInterval(function () {
			  // Speed
			  var point;
			
			  if (chartSpeed) {
			    point = chartSpeed.series[0].points[0];
				
			    var temp_speed = parseInt(data["dcMotor_speed"])
			    if (temp_speed >= 0 || temp_speed < 4095) {
			    	point.update(temp_speed);
			    }
			  }
			}, 1000);
			});
		</script>
	</head>
	<body class="has-sidebar has-fixed-sidebar-and-header">
		<div class="container-fluid">
			<div class="row">
				<!-- ******** 카메라 뷰 ********* -->
				<div class="col-sm-9">
					<div class="row">
						<div class="col-sm-4" align="center">
							<img id="cameraView" style="width: 100%; height: 100%;"/><br/>
							<button class="btn btn-info" onclick="camera_capture()">capture</button>
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
		
		<script>

			var chart1, chart2, chart3, chart4, chart5;
			function makeChart() {
			    chart1 = new Highcharts.Chart({
			        chart: {
			            renderTo: "gas",
			            defaultSeriesType: 'spline'
			        },
			        title: {
			            text: 'Live Gas Data'
			        },
			        xAxis: {
			            type: 'datetime',
			            tickPixelInterval: 100,
			            maxZoom: 20 * 1000
			        },
			        yAxis: {
			            minPadding: 0.2,
			            maxPadding: 0.2,
			            title: {
			                text: 'Value',
			                margin: 20
			            }
			        },
			        series: [{
			            name: 'Gas data',
			            data: [],
			            color:"#F4E442"
			        }]
			    });

			    chart2 = new Highcharts.Chart({
			        chart: {
			            renderTo: "thermistor",
			            defaultSeriesType: 'spline'
			        },
			        title: {
			            text: 'Live Thermistor Data'
			        },
			        xAxis: {
			            type: 'datetime',
			            tickPixelInterval: 100,
			            maxZoom: 20 * 1000
			        },
			        yAxis: {
			            minPadding: 0.2,
			            maxPadding: 0.2,
			            title: {
			                text: 'Value',
			                margin: 20
			            },
			            allowDecimals:false //y축 소수점 허용 안함
			        },
			        series: [{
			            name: 'Thermistor data',
			            data: [],
			            color:"#09C19C"
			        }]
			    });

			    chart3 = new Highcharts.Chart({
			        chart: {
			            renderTo: "photoresister",
			            defaultSeriesType: 'spline'
			        },
			        title: {
			            text: 'Live Photoresister Data'
			        },
			        xAxis: {
			            type: 'datetime',
			            tickPixelInterval: 100,
			            maxZoom: 20 * 1000
			        },
			        yAxis: {
			            minPadding: 0.2,
			            maxPadding: 0.2,
			            title: {
			                text: 'Value',
			                margin: 20
			            }
			        },
			        series: [{
			            name: 'Photoresister data',
			            data: [],
			            color: "#FA1588"
			        }]
			    });

			    chart4 = new Highcharts.Chart({
			        chart: {
			            renderTo: "ultrasonic",
			            defaultSeriesType: 'spline'
			        },
			        title: {
			            text: 'Live Ultrasonic Data'
			        },
			        xAxis: {
			            type: 'datetime',
			            tickPixelInterval: 100,
			            maxZoom: 20 * 1000
			        },
			        yAxis: {
			            minPadding: 0.2,
			            maxPadding: 0.2,
			            title: {
			                text: 'Value',
			                margin: 20
			            }
			        },
			        series: [{
			            name: 'Ultrasonic data',
			            data: [],
			            color: "#8C51FA"
			        }]
			    });

			    chart5 = new Highcharts.Chart({
			        chart: {
			            renderTo: "tracking",
			            defaultSeriesType: 'spline'
			        },
			        title: {
			            text: 'Live Tracking Data'
			        },
			        xAxis: {
			            type: 'datetime',
			            tickPixelInterval: 100,
			            maxZoom: 20 * 1000
			        },
			        yAxis: {
			            minPadding: 0.2,
			            maxPadding: 0.2,
			            title: {
			                text: 'Value',
			                margin: 20
			            }
			        },
			        series: [{
			            name: 'Tracking data',
			            data: [],
			            color: "#5EB5FB"
			        }]
			    });
			}
			jQuery(document).keydown(function(e){	//스크롤 방향키로 안움직이게 하기
				if(e.target.nodeName != "INPUT" && e.target.nodeName != "TEXTAREA"){
					if(e.keyCode === 37 || e.keyCode === 38 || e.keyCode === 39 || e.keyCode === 40 || e.keyCode == 32){
						return false;
					}
				}
			});
			makeChart(); //차트 불러오기
		</script>
	</body>

</html>