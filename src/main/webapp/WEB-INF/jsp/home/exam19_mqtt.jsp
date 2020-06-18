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
			var data;
			var jsonMessage;
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
					//console.log(data);
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
			// -----------------------------------------------------차트
			$(function fun2() {
				var chart1 = Highcharts.chart('container', {
					  chart: {
					    type: 'spline',
					    animation: Highcharts.svg, // don't animate in old IE
					    marginRight: 10,
					    events: {
					      load: function () {
	
					        // set up the updating of the chart each second
					        var series = this.series[0];
					        setInterval(function () {
					          var x = (new Date()).getTime(), 	//현재시간
					          	y = data.gas;
					            //y = Math.random();				//값 넣는 곳
					          series.addPoint([x, y], true, true);
					        }, 1000);
					      }
					    }
					  },
	
					  time: {
					    useUTC: false
					  },
	
					  title: {
					    text: 'Gas chart'
					  },
	
					  accessibility: {
					    announceNewData: {
					      enabled: true,
					      minAnnounceInterval: 15000,
					      announcementFormatter: function (allSeries, newSeries, newPoint) {
					        if (newPoint) {
					          return 'New point added. Value: ' + newPoint.y;
					        }
					        return false;
					      }
					    }
					  },
	
					  xAxis: {
					    type: 'datetime',
					    tickPixelInterval: 150
					  },
	
					  yAxis: {
					    title: {
					      text: 'Value'
					    },
					    plotLines: [{
					      value: 0,
					      width: 1,
					      color: '#808080'
					    }]
					  },
	
					  tooltip: {
					    headerFormat: '<b>{series.name}</b><br/>',
					    pointFormat: '{point.x:%Y-%m-%d %H:%M:%S}<br/>{point.y:.2f}'
					  },
	
					  legend: {
					    enabled: false
					  },
	
					  exporting: {
					    enabled: false
					  },
	
					  series: [{
					    name: '가스 데이터',
					    data: (function () {
					      // generate an array of random data
					      var data = [],
					        time = (new Date()).getTime(),
					        i;
	
					      for (i = -19; i <= 0; i += 1) {
					        data.push({
					          x: time + i * 1000,
					          y: Math.random()
					        });
					      }
					      return data;
					    }())
					  }]
					});
			});
			
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
			    max: 200,
			    title: {
			      text: 'Speed'
			    }
			  },
			
			  credits: {
			    enabled: false
			  },
			
			  series: [{
			    name: 'Speed',
			    data: [80],
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
			
			// The RPM gauge
			var chartRpm = Highcharts.chart('container-rpm', Highcharts.merge(gaugeOptions, {
			  yAxis: {
			    min: 0,
			    max: 5,
			    title: {
			      text: 'RPM'
			    }
			  },
			
			  series: [{
			    name: 'RPM',
			    data: [1],
			    dataLabels: {
			      format:
			        '<div style="text-align:center">' +
			        '<span style="font-size:25px">{y:.1f}</span><br/>' +
			        '<span style="font-size:12px;opacity:0.4">' +
			        '* 1000 / min' +
			        '</span>' +
			        '</div>'
			    },
			    tooltip: {
			      valueSuffix: ' revolutions/min'
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
			    inc = Math.round((Math.random() - 0.5) * 100);
			    newVal = point.y + inc;
			
			    if (newVal < 0 || newVal > 200) {
			      newVal = point.y - inc;
			    }
			
			    point.update(newVal);
			  }
			
			  // RPM
			  if (chartRpm) {
			    point = chartRpm.series[0].points[0];
			    inc = Math.random() - 0.5;
			    newVal = point.y + inc;
			
			    if (newVal < 0 || newVal > 5) {
			      newVal = point.y - inc;
			    }
			
			    point.update(newVal);
			  }
			}, 2000);
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
			<a onclick="fun1()" class="btn btn-success">보내기</a>
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
		<div id="motor_control" onkeydown="onkeydown_handler()">
			<a class="btn btn-danger btn-sm" id="up">↑</a>
			<a class="btn btn-danger btn-sm" id="down">↓</a>
			<a class="btn btn-danger btn-sm" id="left">←</a>
			<a class="btn btn-danger btn-sm" id="right">→</a>
		</div>
		<br/><hr />
				
		<figure class="highcharts-figure">
		  <div id="container"></div>
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
		
	</body>
</html>