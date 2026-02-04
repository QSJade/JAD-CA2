<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="model.BookingCartItem"%>
<%@ page import="java.time.*"%>
<%@ page import="java.time.temporal.ChronoUnit"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Checkout</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%@ include file="../header.jsp" %>

<%
ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
String customerEmail = (String) session.getAttribute("sessCustomerEmail");
String customerAddress = (String) session.getAttribute("sessCustomerAddress");

if (customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

if (cart == null || cart.isEmpty()) {
%>
<p>Your cart is empty.</p>
<%
    return;
}

double grandTotal = 0;
%>

<h2>Booking Summary</h2>
<table border="1">
<tr>
<th>Service</th>
<th>Package</th>
<th>Start Date</th>
<th>End Date</th>
<th>Days</th>
<th>Price/Day</th>
<th>Total</th>
</tr>

<%
for (BookingCartItem item : cart) {
    LocalDate start = LocalDate.parse(item.getStartDate());
    LocalDate end = LocalDate.parse(item.getEndDate());
    long days = ChronoUnit.DAYS.between(start, end) + 1;
    double total = item.getPricePerDay() * days;
    grandTotal += total;
%>
<tr>
<td><%= item.getServiceName() %></td>
<td><%= item.getPackageName() %></td>
<td><%= item.getStartDate() %></td>
<td><%= item.getEndDate() %></td>
<td><%= days %></td>
<td>$<%= String.format("%.2f", item.getPricePerDay()) %></td>
<td>$<%= String.format("%.2f", total) %></td>
</tr>
<% } %>
<tr>
<td colspan="6" style="text-align:right"><strong>Grand Total:</strong></td>
<td>$<%= String.format("%.2f", grandTotal) %></td>
</tr>
</table>

<form action="bookingSubmission.jsp" method="post">
    <input type="submit" value="Confirm & Pay All Bookings" class="btn-pay">
</form>

<%
    session.removeAttribute("cart");
%>

<%@ include file="../footer.jsp" %>
</body>
</html>
