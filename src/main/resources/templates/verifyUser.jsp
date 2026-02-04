<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ page import="at.favre.lib.crypto.bcrypt.BCrypt" %>
    <%--

  - Author(s): Jade
  - Date: 6/11/2025
  - Copyright Notice:
  - @(#)
  - Description: 
  --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
final String PEPPER = "MySuperSecretPepper123!"; 

String email = request.getParameter("email");
String pwd = request.getParameter("password");

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";

    Connection conn = DriverManager.getConnection(connURL);

    String sql = "SELECT * FROM customers WHERE email = ?";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setString(1, email);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
    	String storedHash = rs.getString("password");

    	if (storedHash == null || storedHash.isEmpty()) {
    	    out.println("Stored hash missing!");
    	    return;
    	}
		
        BCrypt.Result result = BCrypt.verifyer()
            .verify((pwd + PEPPER).toCharArray(), storedHash);

        if (result.verified) {
        	String role = rs.getString("role");
        	
            session.setAttribute("sessCustomerId", rs.getInt("customer_id"));
            session.setAttribute("sessCustomerName", rs.getString("name"));
            session.setAttribute("sessCustomerEmail", email);
            session.setAttribute("sessCustomerAddress", rs.getString("address"));
            session.setAttribute("sessUserRole", role);
            

            // send the admin to the admin page
            if ("admin".equalsIgnoreCase(role)) {
                response.sendRedirect("adminService.jsp");
            } else {
                response.sendRedirect("serviceDetails.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?errCode=invalidLogin");
        }

    } else {
        response.sendRedirect("login.jsp?errCode=invalidLogin");
    }

    conn.close();
} catch (Exception e) {
    out.println("Error: " + e);
}
%>
</body>
</html>