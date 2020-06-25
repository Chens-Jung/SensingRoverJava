
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
	client = new Paho.MQTT.Client("192.168.3.183", 61614, new Date().getTime().toString());
	
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

function dataSave() {
	$.ajax({
		
	})
}