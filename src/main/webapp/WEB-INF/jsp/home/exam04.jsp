<%@ page contentType="text/html; charset=UTF-8"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>highcharts</title>
		<link rel="stylesheet" href="<%=application.getContextPath()%>/resources/bootstrap/css/bootstrap.min.css">
		<script src="<%=application.getContextPath()%>/resources/javascript/jquery.min.js"></script>
		<script src="<%=application.getContextPath()%>/resources/bootstrap/js/bootstrap.min.js"></script>	
		
		<script src="<%=application.getContextPath()%>/resources/highcharts/code/highcharts.js"></script>
		<script src="<%=application.getContextPath()%>/resources/highcharts/code/themes/gray.js"></script>
		
		<script>
			var chart;
			function requestData() {
			    $.ajax({
			        url: 'exam04Data',
			        success: function(point) {
			        	//mqtt를 통해서 onmessage가 들어오면 이 코드를 사용하면 됨
			            var series = chart.series[0];
			            var shift = series.data.length > 20;
			            chart.series[0].addPoint(point, true, shift);		//
			            setTimeout(requestData, 1000);    
			        },
			        cache: false
			    });
			}
			$(function() {
			    chart = new Highcharts.Chart({
			        chart: {
			            renderTo: 'container',
			            defaultSeriesType: 'spline',
			            events: {
			            	//사건이 발생하면 drawing을 함
			                load: requestData
			            }
			        },
			        title: {
			            text: 'Live random data'
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
			            name: 'Random data',
			            data: []
			        }]
			    });
			});		
			
			var chart2;
			function requestData2() {
			    $.ajax({
			        url: 'exam04Data',
			        success: function(point) {
			            var series = chart.series[0];
			            var shift = series.data.length > 20;
			            chart2.series[0].addPoint(point, true, shift);
			            setTimeout(requestData2, 2000);    
			        },
			        cache: false
			    });
			}
			$(function() {
			    chart2 = new Highcharts.Chart({
			        chart: {
			            renderTo: 'container2',
			            defaultSeriesType: 'spline',
			            events: {
			                load: requestData2
			            }
			        },
			        title: {
			            text: 'Live random data'
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
			            name: 'Random data',
			            data: []
			        }]
			    });
			});			
		</script>
	</head>
	<body> 
		<div id="container" style="width:100%; height:400px;"></div>
		<div id="container2" style="width:100%; height:400px;"></div>
	</body>
</html>					
					