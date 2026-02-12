<%@ page import="java.sql.*" %>

<%
    String cp = request.getContextPath();
    Integer customerIdCheck = (Integer) session.getAttribute("sessCustomerId");
    String RoleCheck = (String) session.getAttribute("sessUserRole");
%>

<header>
  <nav class="navbar">
    <div class="logo">
      <a href="<%=cp%>/">Silver 47</a>
    </div>

    <ul class="nav-links">
      
      <!-- Home -->
      <li><a href="<%=cp%>/">Home</a></li>

      <!-- Services -->
      <li><a href="<%=cp%>/serviceDetails">Services</a></li>

      <!-- Login / Profile / Logout -->
      <% if (customerIdCheck == null) { %>
          <li><a href="<%=cp%>/login">Login</a></li>
      <% } else { %>
          <li><a href="<%=cp%>/cart/view">Cart</a></li>
          <li><a href="<%=cp%>/profile">Profile</a></li>
          <li><a href="<%=cp%>/logout">Logout</a></li>
      <% } %>

      <!-- Admin Link -->
      <% if ("admin".equals(RoleCheck)) { %>
          <li><a href="<%=cp%>/adminService">Admin</a></li>
      <% } %>
      
    </ul>
  </nav>
</header>
