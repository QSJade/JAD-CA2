<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
// This JSP now just forwards to Spring Controller
String name = request.getParameter("name");
String email = request.getParameter("email");
String pwd = request.getParameter("password");
String address = request.getParameter("address");
String saveAddress = request.getParameter("saveAddress");

// Redirect to Spring controller
response.sendRedirect(request.getContextPath() + "/registerUser?name=" + name + 
                     "&email=" + email + "&password=" + pwd + 
                     "&address=" + address + "&saveAddress=" + saveAddress);
%>
</body>
</html>