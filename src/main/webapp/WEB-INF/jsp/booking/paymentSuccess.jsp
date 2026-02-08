<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Successful</title>
</head>
<body>

<h2>Payment Successful!</h2>
<p>Your booking has been confirmed.</p>
<p><strong>Payment ID:</strong> ${sessionId}</p>

<a href="${pageContext.request.contextPath}/homepage.jsp">Return Home</a>

</body>
</html>
