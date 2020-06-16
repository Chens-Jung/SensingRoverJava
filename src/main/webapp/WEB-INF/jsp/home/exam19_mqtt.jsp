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
				client = new Paho.MQTT.Client(location.hostname, 61614, new Date().getTime.toString());
				
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
				/* console.log(message.payloadString); */
				if(message.destinationName == "/camerapub") {
					var cameraView = $("#cameraView").attr("src", "data:image/jpg;base64," + message.payloadString);
				}
				if(message.destinationName == "/sensor") {
					//console.log(message.payloadString)
					document.getElementById("p").innerHTML = message.payloadString;
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
			    message.destinationName = "/lcd";
			    client.send(message);
			    return false;
			}
		</script>
	</head>
	<body>
		<h5 class="alert alert-info">/home/exam19_mqtt.jsp</h5>
		
		<img id="cameraView"/>
		<p id="p"></p>
		<input type="text" id="lcd0"/>
		<input type="text" id="lcd1"/>
		<a onclick="fun1()" class="btn btn-success">보내기</a>
	</body>
</html>