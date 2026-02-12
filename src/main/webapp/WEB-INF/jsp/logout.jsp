<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ include file="header.jsp" %>

<%
    // Invalidate the session to log the user out
    if (session != null) {
        session.invalidate();
    }
%>

<script>
    alert("You have been logged out successfully!");
    // Redirect to login page after logout
    window.location.href = "homepage";
</script>

<%@ include file="footer.jsp" %>
</body>
</html>