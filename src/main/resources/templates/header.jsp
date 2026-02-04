<%@ page import="java.sql.*" %>

<%
    String cp = request.getContextPath();
    Integer customerIdCheck = (Integer) session.getAttribute("sessCustomerId");
    String RoleCheck = (String) session.getAttribute("sessUserRole");
%>

<header>
  <nav class="navbar">
    <div class="logo">
      <a href="<%=cp%>/assignment1/homepage.jsp">Silver 47</a>
    </div>

    <ul class="nav-links">
      <!-- Home -->
      <li><a href="<%=cp%>/assignment1/homepage.jsp">Home</a></li>

      <!-- Services -->
      <li><a href="<%=cp%>/assignment1/serviceDetails.jsp">Services</a></li>

      <!-- Login / Profile / Logout -->
      <% if (customerIdCheck == null) { %>
          <li><a href="<%=cp%>/assignment1/login.jsp">Login</a></li>
      <% } else { %>
      	<li><a href="<%= cp %>/assignment1/booking/cart/viewCart.jsp">Cart</a></li>
        <li><a href="<%= cp %>/assignment1/profile/profile.jsp">Profile</a></li>
        <li><a href="<%= cp %>/assignment1/logout.jsp">Logout</a></li>
      <% } %>

      <!-- Admin Link -->
      <% if ("admin".equals(RoleCheck)) { %>
          <li><a href="<%=cp%>/assignment1/adminService.jsp">Admin</a></li>
      <% } %>
    </ul>
  </nav>
</header>