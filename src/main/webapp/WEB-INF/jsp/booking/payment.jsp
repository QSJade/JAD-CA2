<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="model.Booking"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.stripe.Stripe"%>
<%@ page import="com.stripe.model.checkout.Session"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Payment Successful</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<jsp:include page="<%= request.getContextPath() %>/header.jsp" />

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
ArrayList<Booking> cart =
        (ArrayList<Booking>) session.getAttribute("cart");

if (customerId == null || cart == null || cart.isEmpty()) {
    out.println("<h2>Invalid session.</h2>");
    return;
}

/* =========================
   VERIFY STRIPE PAYMENT
   ========================= */
 Stripe.apiKey = System.getenv("STRIPE_SECRET_KEY");


String sessionId = request.getParameter("session_id");
if (sessionId == null) {
    out.println("<h2>Missing payment session.</h2>");
    return;
}

Session stripeSession = Session.retrieve(sessionId);

if (!"paid".equals(stripeSession.getPaymentStatus())) {
    out.println("<h2>Payment not completed.</h2>");
    return;
}

/* =========================
   SAVE BOOKINGS TO DATABASE
   ========================= */
try {
    Class.forName("org.postgresql.Driver");
    String connURL =
        "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String insertSQL =
        "INSERT INTO bookings (service_id, package_id, customer_id, customer_email, start_date, end_date, price_per_day, notes, service_address) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    PreparedStatement ps = conn.prepareStatement(insertSQL);

    for (Booking item : cart) {
    	ps.setInt(1, item.getService().getServiceId());
        ps.setInt(2, item.getServicePackage().getPackageId());
        ps.setInt(3, customerId);
        ps.setString(4, stripeSession.getCustomerEmail());
        ps.setDate(5, java.sql.Date.valueOf(item.getStartDate()));
        ps.setDate(6, java.sql.Date.valueOf(item.getEndDate()));
        ps.setDouble(7, item.getPricePerDay());
        ps.setString(8, item.getNotes());
        ps.setString(9, item.getServiceAddress());
        ps.addBatch();
    }

    ps.executeBatch();
    ps.close();
    conn.close();

    session.removeAttribute("cart"); // clear cart AFTER success
%>

<h2>Payment Successful</h2>
<p>Your booking has been confirmed.</p>
<p><strong>Payment ID:</strong> <%= stripeSession.getId() %></p>
<p><strong>Email:</strong> <%= stripeSession.getCustomerEmail() %></p>
<p><strong>Amount Paid:</strong> $<%= stripeSession.getAmountTotal() / 100.0 %></p>

<a href="homepage.jsp">Return Home</a>

<%
} catch (Exception e) {
    out.println("<p>Error saving booking: " + e.getMessage() + "</p>");
}
%>

<jsp:include page="<%= request.getContextPath() %>/footer.jsp" />
</body>
</html>
