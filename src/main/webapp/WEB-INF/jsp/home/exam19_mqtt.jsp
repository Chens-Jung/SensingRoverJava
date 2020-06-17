<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Insert title here</title>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/bootstrap/css/bootstrap.min.css">
		<script src="${pageContext.request.contextPath}/resource/jquery/jquery.min.js"></script>
		<script src="${pageContext.request.contextPath}/resource/popper/popper.min.js"></script>
		<script src="${pageContext.request.contextPath}/resource/bootstrap/js/bootstrap.min.js"></script>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/jquery-ui/jquery-ui.min.css">
		<script src="${pageContext.request.contextPath}/resource/jquery-ui/jquery-ui.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.min.js" type="text/javascript"></script>
		
		<script>
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
			}
		
			function onMessageArrived(message) {
				/* console.log("실행");
				console.log(message.payloadString); */
				if(message.destinationName == "/camerapub") {
					var cameraView = $("#cameraView").attr("src", "data:image/jpg;base64," + message.payloadString);
				}
				if(message.destinationName == "/sensor") {
					//console.log(message.payloadString)
					document.getElementById("p").innerHTML = message.payloadString;
					var jsonObject = JSON.parse(message.payloadString);
					document.getElementById("laser_state").innerHTML = "laser_state : " + jsonObject["laseremmiter_state"];
					document.getElementById("backTire_state").innerHTML = "현재상태 : " + jsonObject["dcMotor_state"];
				}
				
			}
			function fun1() {
				var lcd0c = $("#lcd0").val()
				var lcd1c = $("#lcd1").val()
				var target = {
						lcd0:lcd0c,
						lcd1:lcd1c
				};
				
				message = new Paho.MQTT.Message(JSON.stringify(target));
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
			var isPressed = false;
			
			document.onkeydown = onkeydown_handler;
			document.onkeyup = onkeyup_handler;
			
			function onkeydown_handler(event) {
				var keycode = event.which || event.keycode;
				console.log(keycode);
				if(keycode == 37 || keycode == 39) {
					if(keycode == 37) {
						//left
						var topic = "command/frontTire/left";
						console.log(topic);
					}else if(keycode == 39) {
						//right
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
						var topic = "command/backTire/forward";
					} else if(keycode == 40) {
						// down
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
				
				
			}
			
			function onkeyup_handler(event) {
				var keycode = event.which || event.keycode;
				if(keycode == 37 || keycode == 39) {
					var topic = "command/frontTire/front";
					message = new Paho.MQTT.Message("frontTire");
					message.destinationName = topic;
					client.send(message);
				}
				if(keycode == 38 || keycode == 40) {
					var topic = "command/backTire/respeed";
					message = new Paho.MQTT.Message("backTire");
					message.destinationName = topic;
					client.send(message);
				}
				
			}
			
		</script>
		<style>
			div {
				"width:400px;
				height:110px;
				background-color:gray;
				margin:15px;
				float:left;"
			}
		</style>
	</head>
	<body>
		<h5 class="alert alert-info">/home/exam19_mqtt.jsp</h5>
		
		<img id="cameraView"/>
		<p id="p"></p>
		<div id="lcd" align="center">
			<h3>LCD</h3>
			lcd0:<input type="text" id="lcd0" size="25"/><br/>
			lcd1:<input type="text" id="lcd1" size="25"/>
			<a onclick="fun1()" class="btn btn-success">보내기</a>
		</div>
		<div id="laser" align="center">
			<h3>laser</h3>
			<h6 id="laser_state">laser_state : </h6>
			<button onclick="laser_on()">ON</button>
			<button onclick="laser_off()">OFF</button>
		</div>
		
		<div id="backTire" align="center">
			<h3>BackTire 장치 제어</h3>
			<h6 id="backTire_state">현재 상태 : </h6>
			<button onclick="backTire_control('forward')">전진</button>
			<button onclick="backTire_control('stop')">정지</button>
			<button onclick="backTire_control('backward')">후진</button> <br/>
			<c:forEach var="i" begin="1" end="8">
				<button onclick="backTire_control('0', '${i}')">${i}</button>
			</c:forEach>
		</div>
		<div id="motor_control" onkeydown="onkeydown_handler()">
			<a class="btn btn-danger btn-sm" id="up">↑</a>
			<a class="btn btn-danger btn-sm" id="down">↓</a>
			<a class="btn btn-danger btn-sm" id="left">←</a>
			<a class="btn btn-danger btn-sm" id="right">→</a>
		</div>
		
	</body>
</html>