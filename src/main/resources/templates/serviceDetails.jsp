<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Services Offered</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assignment1/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>



<main class="services-container">
  <section class="intro">
    <h1>Our Care Services</h1>
    <p>Explore our range of personalized care options designed to bring comfort, support, and independence to your loved ones.</p>
  </section>

  <section class="service-grid">
<%

    try {
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        Connection conn = DriverManager.getConnection(connURL);

        // Get all active services
        String sql = "SELECT service_id, service_name, description FROM services WHERE is_active = TRUE ORDER BY service_id";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        while(rs.next()) {
            int serviceId = rs.getInt("service_id");
            String serviceName = rs.getString("service_name");
            String description = rs.getString("description");

            // Map image and page based on service name
            String imgSrc = "images/default-service.jpg"; // default image in case
            String pageLink = "#"; // default link

            if(serviceName.equalsIgnoreCase("In-Home Care")) {
                imgSrc = "images/care.jpg";
                pageLink = "serviceHome.jsp";
            } else if(serviceName.equalsIgnoreCase("Meal Support")) {
                imgSrc = "images/meal-service.jpg";
                pageLink = "serviceMeal.jsp";
            } else if(serviceName.equalsIgnoreCase("Transportation Assistance")) {
                imgSrc = "images/transportation.jpg";
                pageLink = "serviceTransport.jsp";
            }
%>
    <div class="service-card">
        <img src="<%= imgSrc %>" alt="<%= serviceName %>">
        <h3><%= serviceName %></h3>
        <p><%= description %></p>
        <a href="<%= pageLink %>?serviceId=<%= serviceId %>" class="btn-outline">View Details</a>
    </div>
<%
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch(Exception e) {
    	%>
        <p style="color: red;">Error loading services: <%= e.getMessage() %></p>
    	<%
    }
%>
  </section>
</main>

<%@ include file="footer.jsp" %>
</body>
</html>
