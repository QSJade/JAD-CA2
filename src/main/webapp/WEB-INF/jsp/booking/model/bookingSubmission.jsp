<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="model.BookingCartItem"%>
<%@ page import="java.sql.*"%>
<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");
if (cart == null || cart.isEmpty()) {
    response.sendRedirect("viewCart.jsp");
    return;
}

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String insertSQL = "INSERT INTO bookings (service_id, package_id, customer_id, customer_email, start_date, end_date, price_per_day, notes, service_address) " + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    PreparedStatement ps = conn.prepareStatement(insertSQL);

    for (BookingCartItem item : cart) {
        ps.setInt(1, item.getServiceId());
        ps.setInt(2, item.getPackageId());
        ps.setInt(3, customerId);
        ps.setString(4, (String) session.getAttribute("sessCustomerEmail"));
        ps.setDate(5, java.sql.Date.valueOf(item.getStartDate()));
        ps.setDate(6, java.sql.Date.valueOf(item.getEndDate()));
        ps.setDouble(7, item.getPricePerDay());
        ps.setString(8, item.getNotes());
        ps.setString(9, item.getAddress());
        ps.addBatch();
    }

    ps.executeBatch();
    ps.close();
    conn.close();

    // Clear cart after submission
    session.removeAttribute("cart");

    response.sendRedirect("../checkout.jsp"); 
} catch(Exception e) {
    out.println("Error submitting booking: " + e.getMessage());
}
%>
