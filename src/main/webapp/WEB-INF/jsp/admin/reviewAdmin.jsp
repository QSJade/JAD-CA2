<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Review Board</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .review-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    .review-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    .review-card {
        background: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    .review-header-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px solid #eaeaea;
    }
    .customer-name {
        font-size: 18px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .service-name {
        font-size: 14px;
        color: #666;
        margin-left: 10px;
    }
    .rating {
        font-size: 18px;
        font-weight: bold;
        color: #f39c12;
    }
    .comments {
        font-size: 16px;
        line-height: 1.6;
        margin-bottom: 15px;
    }
    .submitted-date {
        font-size: 12px;
        color: #999;
    }
    .btn-delete {
        background: #e74c3c;
        color: white;
        padding: 8px 16px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        margin-top: 10px;
    }
    .btn-delete:hover {
        background: #c0392b;
    }
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<%
String userRole = (String) session.getAttribute("sessUserRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=unauthorized");
    return;
}
%>

<div class="review-container">
    <div class="review-header">
        <h1>Customer Reviews</h1>
        <a href="${pageContext.request.contextPath}/adminService" class="btn-outline">← Back to Dashboard</a>
    </div>

    <%
    try {
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        Connection conn = DriverManager.getConnection(connURL);

        String sql = "SELECT f.feedback_id, f.rating, f.comments, f.created_at, " +
                     "c.name AS customer_name, s.service_name " +
                     "FROM feedbacks f " +
                     "JOIN customers c ON f.customer_id = c.customer_id " +
                     "JOIN services s ON f.service_id = s.service_id " +
                     "ORDER BY f.created_at DESC";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        boolean hasReviews = false;

        while(rs.next()) {
            hasReviews = true;
            int id = rs.getInt("feedback_id");
            int rating = rs.getInt("rating");
            String comments = rs.getString("comments");
            String customer = rs.getString("customer_name");
            String service = rs.getString("service_name");
            Timestamp created = rs.getTimestamp("created_at");
    %>
    
    <div class="review-card">
        <div class="review-header-info">
            <div>
                <span class="customer-name"><%= customer %></span>
                <span class="service-name"><%= service %></span>
            </div>
            <div class="rating">
                <% for(int i = 1; i <= 5; i++) { %>
                    <%= i <= rating ? "★" : "☆" %>
                <% } %>
                (<%= rating %>/5)
            </div>
        </div>
        <div class="comments">"<%= comments %>"</div>
        <div class="submitted-date">Submitted: <%= created %></div>
        <form action="${pageContext.request.contextPath}/admin/deleteReview" method="post" 
              onsubmit="return confirm('Are you sure you want to delete this review?');">
            <input type="hidden" name="id" value="<%= id %>">
            <button type="submit" class="btn-delete">Delete Review</button>
        </form>
    </div>

    <%
        }
        if (!hasReviews) {
    %>
        <div style="text-align: center; padding: 60px; background: white; border-radius: 10px;">
            <div style="font-size: 48px; margin-bottom: 20px;">⭐</div>
            <h3 style="color: #666; margin-bottom: 10px;">No Reviews Yet</h3>
            <p style="color: #999;">Customer reviews will appear here once submitted.</p>
        </div>
    <%
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color: red; padding: 20px;'>Error: " + e.getMessage() + "</div>");
    }
    %>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>