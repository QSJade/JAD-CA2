<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.BookingCartItem" %>
<%
ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Cart</title>
<link rel="stylesheet" href="../../css/style.css">
</head>
<body>
<%@ include file="../../header.jsp" %>

<h1>Your Cart</h1>

<%
if (cart == null || cart.isEmpty()) {
%>
    <p>Your cart is empty.</p>
<%
} else {
%>
    <form action="updateCart.jsp" method="post" onsubmit="return validateCartDates();">
	<div style="overflow-x:auto;">
	<table border="1" style="width:100%; border-collapse: collapse;">
	    <tr>
	        <th>Service</th>
	        <th>Package</th>
	        <th>Start Date</th>
	        <th>End Date</th>
	        <th>Days</th>
	        <th>Price/Day</th>
	        <th>Total</th>
	        <th>Actions</th>
	    </tr>
	<%
	int index = 0;
	double grandTotal = 0;
	java.time.LocalDate today = java.time.LocalDate.now();
	String todayStr = today.toString(); // e.g., "2025-11-28"

	for (BookingCartItem item : cart) {
	    java.time.LocalDate start = java.time.LocalDate.parse(item.getStartDate());
	    java.time.LocalDate end = java.time.LocalDate.parse(item.getEndDate());
	    long days = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1; // inclusive
	    double total = days * item.getPricePerDay();
	    grandTotal += total;
	%>
	    <tr>
	        <td><%= item.getServiceName() %></td>

            <!-- Package dropdown -->
            <td>
                <select name="packageId_<%= index %>">
                    <option value="1" <%= item.getPackageId() == 1 ? "selected" : "" %>>Gold</option>
                    <option value="2" <%= item.getPackageId() == 2 ? "selected" : "" %>>Silver</option>
                    <option value="3" <%= item.getPackageId() == 3 ? "selected" : "" %>>Bronze</option>
                </select>
            </td>

	        <td><input type="date" name="startDate_<%= index %>" value="<%= item.getStartDate() %>" min="<%= todayStr %>"></td>
	        <td><input type="date" name="endDate_<%= index %>" value="<%= item.getEndDate() %>" min="<%= todayStr %>"></td>

	        <td><%= days %></td>
	        <td>$<%= String.format("%.2f", item.getPricePerDay()) %></td>
	        <td>$<%= String.format("%.2f", total) %></td>
	        <td><a href="deleteCart.jsp?index=<%= index %>">Delete</a></td>
	    </tr>
	<%
	    index++;
	}
	%>
	<tr>
	    <td colspan="6" style="text-align:right"><strong>Grand Total:</strong></td>
	    <td colspan="2">$<%= String.format("%.2f", grandTotal) %></td>
	</tr>
	</table>
	</div>

        <input type="hidden" name="size" value="<%= cart.size() %>">
        <input type="submit" value="Update Cart">
    </form>

    <%-- Submit Cart Form --%>
	<form action="../model/bookingSubmission.jsp" method="post">
	    <input type="submit" value="Submit Booking">
	</form>
<%
}
%>

<%@ include file="../../footer.jsp" %>

<script>
function validateCartDates() {
    const rows = document.querySelectorAll("table tr");
    for (let i = 1; i < rows.length - 1; i++) { // skip header & total row
        const startInput = rows[i].querySelector("input[name^='startDate_']");
        const endInput = rows[i].querySelector("input[name^='endDate_']");
        if (startInput && endInput) {
            if (new Date(endInput.value) < new Date(startInput.value)) {
                alert("End Date cannot be earlier than Start Date!");
                return false;
            }
        }
    }
    return true;
}
</script>

</body>
</html>
