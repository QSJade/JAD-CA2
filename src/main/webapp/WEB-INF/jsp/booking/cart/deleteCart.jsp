<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.BookingCartItem" %>
<%
int index = Integer.parseInt(request.getParameter("index"));
ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");

if (cart != null && index >= 0 && index < cart.size()) {
    cart.remove(index);
}

response.sendRedirect("viewCart.jsp");
%>
