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