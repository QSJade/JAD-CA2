<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add New Service</title>
<link rel="stylesheet" href="css/style.css">
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f7f7f7;
        margin: 0;
    }

    .main-content {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding: 40px 0;
        min-height: calc(100vh - 100px);
        box-sizing: border-box;
    }

    .form-container {
        background: #fff;
        padding: 30px 40px;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        width: 400px;
        max-width: 90%;
        text-align: center;
    }

    .form-container h2 {
        margin-bottom: 20px;
        font-weight: normal;
    }

    .form-group {
        margin-bottom: 15px;
        text-align: left;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-size: 14px;
    }

    .form-group input,
    .form-group textarea {
        width: 100%;
        padding: 8px 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
        font-size: 14px;
        box-sizing: border-box;
    }

    .form-group textarea {
        resize: vertical;
        min-height: 80px;
    }

    .btn-add {
        background-color: #28a745;
        color: #fff;
        border: none;
        padding: 10px 25px;
        border-radius: 5px;
        cursor: pointer;
        font-size: 14px;
    }

    .btn-add:hover {
        background-color: #218838;
    }

    .msg {
        margin-bottom: 15px;
        font-weight: bold;
    }
</style>
</head>
<body>

<jsp:include page="<%= request.getContextPath() %>/header.jsp" />

<div class="main-content">
    <div class="form-container">
        <h2>Add New Service</h2>

        <!-- ==========================
             BACKEND JSP INSERT LOGIC
        =========================== -->
        <%
        String serviceName = request.getParameter("serviceName");
        String serviceDetails = request.getParameter("serviceDetails");
        String price = request.getParameter("price");

        if (serviceName != null && serviceDetails != null && price != null) {
            try {
                Class.forName("org.postgresql.Driver");

                String connURL =
                 "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";

                Connection conn = DriverManager.getConnection(connURL);

                String sql = "INSERT INTO services (service_name, description, price_per_day, is_active, created_at) VALUES (?, ?, ?, TRUE, NOW())";
                PreparedStatement ps = conn.prepareStatement(sql);

                ps.setString(1, serviceName);
                ps.setString(2, serviceDetails);
                ps.setBigDecimal(3, new java.math.BigDecimal(price));

                int rows = ps.executeUpdate();

                if (rows > 0) {
                    out.println("<p class='msg' style='color:green;'>Service added successfully!</p>");
                } else {
                    out.println("<p class='msg' style='color:red;'>Failed to add service.</p>");
                }

                ps.close();
                conn.close();

            } catch (Exception e) {
                out.println("<p class='msg' style='color:red;'>Error: " + e.getMessage() + "</p>");
            }
        }
        %>

        <!-- ==========================
               HTML FORM
        =========================== -->
        <form action="addService.jsp" method="post">
            <div class="form-group">
                <label for="serviceName">Name:</label>
                <input type="text" id="serviceName" name="serviceName" required>
            </div>

            <div class="form-group">
                <label for="serviceDetails">Details:</label>
                <textarea id="serviceDetails" name="serviceDetails" required></textarea>
            </div>

            <div class="form-group">
                <label for="price">Price Per Day:</label>
                <input type="number" id="price" name="price" step="0.01" required>
            </div>

            <button type="submit" class="btn-add">Add</button>
        </form>
    </div>
</div>

<jsp:include page="<%= request.getContextPath() %>/footer.jsp" />
</body>
</html>
