<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

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
		
		<script src="http://code.highcharts.com/highcharts.js"></script>
		<script src="http://code.highcharts.com/modules/exporting.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
		
		<script>
		$(function () { 
		    var myChart = Highcharts.chart('container1', {
		        chart: {
		            type: 'line'
		        },
		        title: {
		            text: '그래프 제목맨'
		        },

		        subtitle: {
		            text: '예를 들어 온도센서',
		            x: -20
		        },

		        xAxis: {
		        	title: {
		                text: '단위(도)'
		            },
		            categories: ['시점1', '시점2', '시점3', '시점4', '시점5', '시점6', '시점7', '시점8', '시점9', '시점10']
		        },
		        yAxis: {
		            title: {
		                text: '값'
		            },
		            plotLines: [{
		                value: 0,
		                width: 1,
		                color: '#808080'
		            }]
		        },

		        series: [{
		            name: 'ex.온도값',
		            data: [25,50,29,32,31,18,39,36,22,40]
		        }],

		        legend: {
		            layout: 'vertical',
		            align: 'right',
		            verticalAlign: 'middle',
		            borderWidth: 0
		        },
		        tooltip: {
		            valueSuffix: '도(단위)'
		        }
		    });
		});
		
		//---------------------------------
		$(function () {
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
				            y = Math.random();				//값 넣는 곳
				          series.addPoint([x, y], true, true);
				        }, 1000);
				      }
				    }
				  },
	
				  time: {
				    useUTC: false
				  },
	
				  title: {
				    text: '라이브 차트맨'
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
				    name: '랜덤 데이터',
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
		</script>
		
		<style>
		//레이아웃----------------------------------
			.wrapper { 
			  display: grid; 
			  grid-template-columns: repeat(3, 1fr); 
			  grid-auto-rows: 100px; 
			} 
			
			.box1 { 
			  grid-column-start: 1; 
			  grid-column-end: 4; 
			  grid-row-start: 1; 
			  grid-row-end: 3; 
			}
			
			.box2 { 
			  grid-column-start: 1; 
			  grid-row-start: 3; 
			  grid-row-end: 5; 
			}
			
			
			//하이차트 ----------------------------------------------------------
			.highcharts-figure, .highcharts-data-table table {
			  min-width: 320px; 
			  max-width: 800px;
			  margin: 1em auto;
			}
			
			#container {
			  height: 400px;
			}
			
			.highcharts-data-table table {
			  font-family: Verdana, sans-serif;
			  border-collapse: collapse;
			  border: 1px solid #EBEBEB;
			  margin: 10px auto;
			  text-align: center;
			  width: 100%;
			  max-width: 500px;
			}
			.highcharts-data-table caption {
			  padding: 1em 0;
			  font-size: 1.2em;
			  color: #555;
			}
			.highcharts-data-table th {
			  font-weight: 600;
			  padding: 0.5em;
			}
			.highcharts-data-table td, .highcharts-data-table th, .highcharts-data-table caption {
			  padding: 0.5em;
			}
			.highcharts-data-table thead tr, .highcharts-data-table tr:nth-child(even) {
			  background: #f8f8f8;
			}
			.highcharts-data-table tr:hover {
			  background: #f1f7ff;
			}
			 ?>
		</style>
	</head>
	<body>
		
		<div class="wrapper">
		  <div class="box1">
		  <h5 class="alert alert-info">/home/main.jsp</h5>
		  </div>
		  <div class="box2">
		  	<ul>
				<li><a href="exam19_mqtt.do">exam19_mqtt.do</a></li>
				<li><a href="dashboard.do">dashboard.do</a></li>
				
			</ul>
		  </div>
		  <div class="box3">
		  <div class="data" id="container1" style="width:1000px; height:100%;"></div></div>
		  <div class="box4">
		  <script src="https://code.highcharts.com/highcharts.js"></script>
		<script src="https://code.highcharts.com/modules/exporting.js"></script>
		<script src="https://code.highcharts.com/modules/export-data.js"></script>
		<script src="https://code.highcharts.com/modules/accessibility.js"></script>
		
		<figure class="highcharts-figure">
		  <div id="container" style="margin: 20%"></div>
		  <p class="highcharts-description">
		    Chart showing data updating every second, with old data being removed.
		  </p>
		</figure></div>
		  <div class="box5">Five</div>
		</div>
		
		
	</body>
</html>