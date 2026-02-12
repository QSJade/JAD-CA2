<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

// Error handling
String errCode = request.getParameter("errCode");
if (errCode != null && errCode.equals("insertFail")) {
    out.println("<p style='color: red;'>One of your values are wrong. Please try again.</p>");
}
%>

<h1 class="booking-title">Booking Details</h1>

<form action="${pageContext.request.contextPath}/cart/add" method="post" class="form-wrapper" onsubmit="return validateDates();">
    <input type="hidden" name="serviceId" value="<%= serviceId %>">
    <input type="hidden" name="packageId" value="<%= packageId %>">
    <input type="hidden" name="serviceName" value="<%= serviceName %>">
    <input type="hidden" name="packageName" value="<%= packageName %>">

    <!-- Service and Package (display only) -->
    <div class="form-row">
        <label>Service:</label>
        <input type="text" value="<%= serviceName %>" readonly>
    </div>

    <div class="form-row">
        <label>Package:</label>
        <input type="text" value="<%= packageName %>" readonly>
    </div>

    <!-- Contact details -->
    <div class="form-row">
        <label>Name:</label>
        <input type="text" name="name" value="<%= customerName %>" readonly>
    </div>

    <div class="form-row">
        <label>Email:</label>
        <input type="email" name="email" value="<%= customerEmail %>" readonly>
    </div>

    <!-- Address -->
    <div class="form-row">
        <label>Service Address:</label>
        <input type="text" name="service_address" value="<%= customerAddress != null ? customerAddress : "" %>" required>
    </div>
       
    <!-- Dates -->
    <%
        java.time.LocalDate today = java.time.LocalDate.now();
        String todayStr = today.toString();
    %>
    
    <div class="form-row">
        <label>Start Date:</label>
        <input type="date" name="startDate" required min="<%= todayStr %>">
    </div>
    
    <div class="form-row">
        <label>End Date:</label>
        <input type="date" name="endDate" required min="<%= todayStr %>">
    </div>

    <!-- Additional notes -->
    <div class="form-row">
        <label>Notes:</label>
        <input type="text" name="notes">
    </div>

    <div class="button-row">
        <input type="submit" name="btnSubmit" value="Continue">
    </div>
</form>

<%@ include file="../footer.jsp" %>

<script>
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