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
out.println("BCrypt class = " + BCrypt.class);

String name = request.getParameter("name");
String email = request.getParameter("email");
String pwd = request.getParameter("password");
String address = request.getParameter("address");
String saveAddress = request.getParameter("saveAddress");

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // Check duplicate email
    PreparedStatement checkPs = conn.prepareStatement(
        "SELECT email FROM customers WHERE email = ?"
    );
    checkPs.setString(1, email);
    ResultSet rs = checkPs.executeQuery();

    if (rs.next()) {
        response.sendRedirect("register.jsp?errCode=duplicateEmail");
        conn.close();
        return;
    }

    // Hash password + pepper
    String bcryptHash = BCrypt.withDefaults()
        .hashToString(12, (pwd + PEPPER).toCharArray());

    // Insert
    String sql;
	if ("yes".equals(saveAddress)) {
	    sql = "INSERT INTO customers (name, email, password, role, address) VALUES (?,?,?,?,?)";
	} else {
	    sql = "INSERT INTO customers (name, email, password, role) VALUES (?,?,?,?)";
	}
	
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setString(1, name);
	ps.setString(2, email);
	ps.setString(3, bcryptHash);
	
	if ("yes".equals(saveAddress)) {
	    ps.setString(4, "customer");
	    ps.setString(5, address);
	} else {
	    ps.setString(4, "customer");  
	}

    int rows = ps.executeUpdate();

    if (rows > 0) {
        response.sendRedirect("login.jsp");
    } else {
        response.sendRedirect("register.jsp?errCode=invalidLogin");
    }

    conn.close();
} catch (Exception e) {
    out.println("Error: " + e);
}
%>
</body>
</html>