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
					document.getElementById("buzzer_state").innerHTML = "buzzer_state : " + jsonObject["buzzer_state"];
					document.getElementById("backTire_state").innerHTML = "현재상태 : " + jsonObject["dcMotor_state"];
					document.getElementById("rgbLed_state").innerHTML = "rgbLed_state : " + jsonObject["rgbLed_state"];

					data = jsonObject;
					// console.log(data.dcMotor_speed);
					document.getElementById("backTire_state").innerHTML = "현재상태 : " + jsonObject["dcMotor_state"];
				
					//차트 설정================================================================================
					var x = (new Date()).getTime();
					//console.log("x:", x);

					var y1 = data.gas;
					//var y1 = Math.random();
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
				}
				
			}
			function lcd_write() {
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
			
			function buzzer_active() {
				console.log(data.ultrasonic);
				if(data.ultrasonic < 5.0){
					console.log(data.ultrasonic);
					
					message = new Paho.MQTT.Message("active")
					message.destinationName = "command/buzzer/active";
					client.send(message);
				}
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
			function dist(ang){
				if(ang == "0"){
					message = new Paho.MQTT.Message("0")
					message.destinationName = "command/dist/left";
					client.send(message);
				}
				else if(ang == "90"){
					message = new Paho.MQTT.Message("90")
					message.destinationName = "command/dist/middle";
					client.send(message);
				}
				else if(ang == "180"){
					message = new Paho.MQTT.Message("180")
					message.destinationName = "command/dist/right";
					client.send(message);
				}
				console.log(message.destinationName);
			}

			function moterx(ang){
				if(ang == "0"){
					message = new Paho.MQTT.Message("0")
					message.destinationName = "command/moterx/left";
					client.send(message);
				}
				else if(ang == "90"){
					message = new Paho.MQTT.Message("90")
					message.destinationName = "command/moterx/middle";
					client.send(message);
				}
				else if(ang == "180"){
					message = new Paho.MQTT.Message("180")
					message.destinationName = "command/moterx/right";
					client.send(message);
				}
				console.log(message.destinationName);
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
			//게이지----------------
			
			$(function(){var gaugeOptions = {
			  chart: {
			    type: 'solidgauge'
			  },
			
			  title: null,
			
			  pane: {
			    center: ['50%', '85%'],
			    size: '140%',
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
			  var point,
			    newVal,
			    inc;
			
			  if (chartSpeed) {
			    point = chartSpeed.series[0].points[0];
				
			    var temp_speed = parseInt(data["dcMotor_speed"])
			    if (temp_speed >= 0 || temp_speed < 4095) {
			    	point.update(temp_speed);
			    }
			
			    
			  }
			}, 1000);
			});
			
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
	</head>
	<body>
	
		<h5 class="alert alert-info">/home/exam19_mqtt.jsp</h5>
		
		<img id="cameraView"/>
		<p id="p"></p>
		<div id="lcd" align="center">
			<h3>LCD</h3>
			lcd0:<input type="text" id="lcd0" size="25"/><br/>
			lcd1:<input type="text" id="lcd1" size="25"/>
			<a onclick="lcd_write()" class="btn btn-success">보내기</a>
		</div>
		<div id="laser" align="center">
			<h3>laser</h3>
			<h6 id="laser_state">laser_state : </h6>
			<button onclick="laser_on()">ON</button>
			<button onclick="laser_off()">OFF</button>
		</div>
		
		<div id="buzzer" align="center">
			<h3>buzzer</h3>
			<h6 id="buzzer_state">buzzer_state : </h6>
			<button onclick="buzzer_on()">ON</button>
			<button onclick="buzzer_off()">OFF</button>
			<button onclick="buzzer_active()">ACTIVE</button>
		</div>
		
		<div id="rgbLed" align="center">
			<h3>RGB LED</h3>
			<h6 id="rgbLed_state">rgbLed_state : </h6>
			<button onclick="rgbLed_red()">RED</button>
			<button onclick="rgbLed_green()">GREEN</button>
			<button onclick="rgbLed_blue()">BLUE</button>
			<button onclick="rgbLed_off()">OFF</button>
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
		
		<div>
			<button onclick="dist('0')">0도</button>
			<button onclick="dist('90')">90도</button>
			<button onclick="dist('180')">180도</button>

		</div>

		<div>
			<button onclick="moterx('0')">0도</button>
			<button onclick="moterx('90')">90도</button>
			<button onclick="moterx('180')">180도</button>
		</div>
		
		<br/><hr />
				
		<figure class="highcharts-figure">
		  <div id="gas" style="margin: 10%" ></div>
		  <div id="thermistor" style="margin: 10%" ></div>
		  <div id="photoresister" style="margin: 10%" ></div>
		  <div id="ultrasonic" style="margin: 10%" ></div>
		  <div id="tracking" style="margin: 10%" ></div>
		  <p class="highcharts-description">
		    	센서 차트
		  </p>
		</figure>
		
		<br/><hr />
		
		
		
		<figure class="highcharts-figure">
		  <div id="container-speed" class="chart-container"></div>
		  <div id="container-rpm" class="chart-container"></div>
		  <p class="highcharts-description">
		    	게이지
		  </p>
		</figure>
		
		<figure class="highcharts-figure">
		  <div id="gas" style="margin: 10%" ></div>
		  <div id="thermistor" style="margin: 10%" ></div>

		</figure>
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
			                margin: 80
			            }
			        },
			        series: [{
			            name: 'Gas data',
			            data: []
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
			                margin: 80
			            },
			            allowDecimals:false //y축 소수점 허용 안함
			        },
			        series: [{
			            name: 'Thermistor data',
			            data: []
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
			                margin: 80
			            }
			        },
			        series: [{
			            name: 'Photoresister data',
			            data: []
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
			                margin: 80
			            }
			        },
			        series: [{
			            name: 'Ultrasonic data',
			            data: []
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
			                margin: 80
			            }
			        },
			        series: [{
			            name: 'Tracking data',
			            data: []
			        }]
			    });
			}
			makeChart(); //차트 불러오기
		</script>
	</body>
</html>