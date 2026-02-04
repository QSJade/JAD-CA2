<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="../header.jsp" %>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
String customerName = (String) session.getAttribute("sessCustomerName");
String customerEmail = (String) session.getAttribute("sessCustomerEmail");
String customerAddress = (String) session.getAttribute("sessCustomerAddress");
Integer packageId = null;
Integer serviceId = null;
String serviceName = "";
String packageName = "";

try {
    serviceId = Integer.parseInt(request.getParameter("serviceId"));
    packageId = Integer.parseInt(request.getParameter("packageId"));

    // Load service and package names from DB
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    PreparedStatement psService = conn.prepareStatement("SELECT service_name FROM services WHERE service_id = ?");
    psService.setInt(1, serviceId);
    ResultSet rsService = psService.executeQuery();
    if(rsService.next()) {
        serviceName = rsService.getString("service_name");
    }

    PreparedStatement psPackage = conn.prepareStatement("SELECT package_name FROM packages WHERE package_id = ?");
    psPackage.setInt(1, packageId);
    ResultSet rsPackage = psPackage.executeQuery();
    if(rsPackage.next()) {
        packageName = rsPackage.getString("package_name");
    }

    conn.close();
} catch(Exception e) {
    out.println("<p>Invalid service or package selected.</p>");
    return;
}

// Check if logged in
if(customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

// Error handling
String errCode = request.getParameter("errCode");
if (errCode != null && errCode.equals("insertFail")) {
    out.println("<p style='color: red;'>One of your values are wrong. Please try again.</p>");
}
%>

<h1 class="booking-title">Booking Details</h1>

<form action="cart/addToCart.jsp" method="post" class="form-wrapper" onsubmit="return validateDates();">
    <input type="hidden" name="serviceId" value="<%= serviceId %>">
    <input type="hidden" name="packageId" value="<%= packageId %>">

    <!-- Service and Package -->
    <label for="service">Service:</label>
    <input type="text" name="serviceName" value="<%= serviceName %>" readonly><br><br>

    <label for="package">Package:</label>
    <input type="text" name="packageName" value="<%= packageName %>" readonly><br><br>

    <!-- Contact details -->
    <label for="name">Name:</label>
    <input type="text" name="name" value="<%= customerName %>" readonly><br><br>

    <label for="email">Email:</label>
    <input type="email" name="email" value="<%= customerEmail %>" readonly><br><br>

	<!-- Address -->
	<label for="service_address">Service Address:</label>
	<input type="text" name="service_address" value="<%= customerAddress %>" required><br><br>
       
    <!-- Dates -->
<%
    // Get today's date
    java.time.LocalDate today = java.time.LocalDate.now();
    String todayStr = today.toString(); // get the date only
%>
    
	<label for="startDate">Start Date:</label>
	<input type="date" name="startDate" required min="<%= todayStr %>"><br><br>
	
	<label for="endDate">End Date:</label>
	<input type="date" name="endDate" required min="<%= todayStr %>"><br><br>

    <!-- Additional notes -->
    <label for="notes">Notes:</label>
    <input type="text" name="notes"><br><br>

    <input type="submit" name="btnSubmit" value="Continue">
</form>

<%@ include file="../footer.jsp" %>

<script>
// Validate that end date is not earlier than start date
function validateDates() {
    const startDate = document.querySelector("input[name='startDate']").value;
    const endDate = document.querySelector("input[name='endDate']").value;

    if (new Date(endDate) < new Date(startDate)) {
        alert("End Date cannot be earlier than Start Date!");
        return false;
    }
    return true;
}
</script>

</body>
</html>
