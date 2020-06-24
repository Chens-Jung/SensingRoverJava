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
		<style>
			#jb-container {
			  width: 100%;
			  height: 100%;
			  margin: 0px;
			}
			#jb-content {
			  width: 75%;
			  height: 100%;
			  margin-bottom: 20px;
			  float: left;
			  border: 1px solid #bcbcbc;
			}
			#jb-content .mainContent {
			  width:180px;
			  height:180px;
			  border: 1px solid #bcbcbc;
			  margin-left:10px;
			  margin-right:10px;
			  display: inline-block;
			}
			#jb-content #row_1 {
			  width: 100%;
			  height:25%;
			  margin-bottom: 10px;
			  border: 1px solid #bcbcbc;
			}
			#jb-content #row_2 {
				width: 100%;
				height: 25%;
				margin-bottom: 10px;
			  
			}
			#jb-content #row_3 {
			  width: 100%;
			  height:25%;
			  margin-bottom: 10px;
			  border: 1px solid #bcbcbc;
			}
			#jb-content #row_4 {
			  width: 100%;
			  height:25%;
			  margin-bottom: 10px;
			  border: 1px solid #bcbcbc;
			}
			#jb-sidebar {
			  width: 25%;
			  height:100%;
			  padding: 5px;
			  margin-bottom: 20px;
			  float: right;
			  border: 1px solid #bcbcbc;
			}
			#jb-sidebar .content {
			  width: 100%;
			  padding: 20px;
			  margin-bottom: 10px;
			  float: right;
			  border: 1px solid #bcbcbc;
			}
	    </style>
    </head>
	<body>
		<div id="jb-container">
			<div id="jb-content">
				<div id="row_1" style="display:block;">
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					
				</div>
				<div id="row_2" style="display:block;">
					<div class="mainContent">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
				</div>
				<div id="row_3" style="display:block;">
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
				</div>
				<div id="row_4" style="display:block;">
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
					<div class="mainContent" style="display: inline-block;">
						<h2>Content</h2>
						<p>블록 하나</p>
					</div>
				</div>
				
				
			</div>
			<div id="jb-sidebar">
				<div>
					<div class="content">
						<h2>Sidebar</h2>
						<ul>
						  <li>Lorem</li>
						  <li>Ipsum</li>
						  <li>Dolor</li>
						</ul>
					</div>
					<div class="content">
						<h2>Sidebar</h2>
						<ul>
						  <li>Lorem</li>
						  <li>Ipsum</li>
						  <li>Dolor</li>
						</ul>
					</div>
					<div class="content">
						<h2>Sidebar</h2>
						<ul>
						  <li>Lorem</li>
						  <li>Ipsum</li>
						  <li>Dolor</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>