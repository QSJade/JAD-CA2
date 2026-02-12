<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookingCartItem" %>
<%
List<BookingCartItem> cart = (List<BookingCartItem>) request.getAttribute("cartItems");
Double subtotal = (Double) request.getAttribute("subtotal");
Double gst = (Double) request.getAttribute("gst");
Double total = (Double) request.getAttribute("total");
Boolean isEmpty = (Boolean) request.getAttribute("isEmpty");

if (cart == null) {
    response.sendRedirect(request.getContextPath() + "/cart/view");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Cart</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .action-buttons {
        display: flex;
        gap: 8px;
        justify-content: center;
        align-items: center;
    }
    .btn-update-item {
        background-color: #4CAF50;
        color: white;
        padding: 6px 12px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        text-decoration: none;
    }
    .btn-update-item:hover {
        background-color: #23913f;
    }
    .btn-delete-item {
        background-color: #e74c3c;
        color: white;
        padding: 6px 12px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
    }
    .btn-delete-item:hover {
        background-color: #b71c1c;
    }
    .delete-form {
        display: inline;
        margin: 0;
        padding: 0;
    }
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<h1>Your Cart</h1>

<%
if (isEmpty || cart.isEmpty()) {
%>
    <p>Your cart is empty.</p>
<%
} else {
%>
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
    for (BookingCartItem item : cart) {
        java.time.LocalDate start = java.time.LocalDate.parse(item.getStartDate());
        java.time.LocalDate end = java.time.LocalDate.parse(item.getEndDate());
        long days = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1;
        double itemTotal = days * item.getPricePerDay();
    %>
        <tr>
            <td><%= item.getServiceName() %></td>
            <td>
                <select name="packageId_<%= index %>" form="updateForm">
                    <option value="1" <%= item.getPackageId() == 1 ? "selected" : "" %>>Gold</option>
                    <option value="2" <%= item.getPackageId() == 2 ? "selected" : "" %>>Silver</option>
                    <option value="3" <%= item.getPackageId() == 3 ? "selected" : "" %>>Bronze</option>
                </select>
                <input type="hidden" name="serviceId_<%= index %>" value="<%= item.getServiceId() %>" form="updateForm">
            </td>
            <td><input type="date" name="startDate_<%= index %>" value="<%= item.getStartDate() %>" form="updateForm"></td>
            <td><input type="date" name="endDate_<%= index %>" value="<%= item.getEndDate() %>" form="updateForm"></td>
            <td><%= days %></td>
            <td>$<%= String.format("%.2f", item.getPricePerDay()) %></td>
            <td>$<%= String.format("%.2f", itemTotal) %></td>
            <td>
                <div class="action-buttons">
                    <%-- Update button for this specific row --%>
                    <button type="submit" form="updateForm" name="updateIndex" value="<%= index %>" class="btn-update-item">Update</button>
                    
                    <%-- Delete button as form button, not link --%>
                    <form action="${pageContext.request.contextPath}/cart/remove/<%= index %>" method="post" class="delete-form" onsubmit="return confirm('Remove this item?');">
                        <button type="submit" class="btn-delete-item">Delete</button>
                    </form>
                </div>
            </td>
        </tr>
    <%
        index++;
    }
    %>
    <tr>
        <td colspan="6" style="text-align:right"><strong>Subtotal:</strong></td>
        <td colspan="2">$<%= String.format("%.2f", subtotal) %></td>
    </tr>
    <tr>
        <td colspan="6" style="text-align:right"><strong>GST (9%):</strong></td>
        <td colspan="2">$<%= String.format("%.2f", gst) %></td>
    </tr>
    <tr>
        <td colspan="6" style="text-align:right"><strong>Total:</strong></td>
        <td colspan="2">$<%= String.format("%.2f", total) %></td>
    </tr>
    </table>
    </div>

    <%-- Single update form for all rows --%>
    <form id="updateForm" action="${pageContext.request.contextPath}/cart/update" method="post" style="display: none;">
        <input type="hidden" name="size" value="<%= cart.size() %>">
    </form>

    <div style="text-align: center; margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/cart/checkout" class="book-btn">Proceed to Checkout</a>
    </div>
<%
}
%>

<%@ include file="../footer.jsp" %>

<script>
function validateCartDates() {
    return true;
}
</script>

</body>
</html>