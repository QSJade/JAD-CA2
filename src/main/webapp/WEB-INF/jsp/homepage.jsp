<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <!--
  - Author(s): Jade
  - Date: 27/10/2025
  - Copyright Notice:
  - @(#)
  - Description: Homepage with Elderly Care Services
  -->
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>Homepage</title>
</head>
<body>
<%@ include file="header.jsp" %>
<!-- image carousel -->
<main class="home-container">
  <section class="hero">
    <div class="hero-carousel">
      <div class="carousel-slide fade">
        <img src="images/elderly-care.jpg" alt="Elderly care service">
      </div>
      <div class="carousel-slide fade">
        <img src="images/caregiver-smile.jpg" alt="Professional caregiver smiling">
      </div>
      <div class="carousel-slide fade">
        <img src="images/family-support.jpg" alt="Family and elderly care">
      </div>

      <!-- Carousel navigation dots -->
      <div class="carousel-dots">
        <span class="dot" onclick="currentSlide(1)"></span>
        <span class="dot" onclick="currentSlide(2)"></span>
        <span class="dot" onclick="currentSlide(3)"></span>
      </div>
    </div>
  </section>

  <!-- Elderly Care Guide Section -->
  <section class="about">
    <h2>Guide to Elderly Care</h2>
    <p>As our loved ones age, their needs evolve, often requiring more focused care. If a once-independent parent begins struggling with daily activities like cooking, managing appointments, or getting around, it may be a sign they need additional support.</p>
    <p>Elderly care provides assistance with everyday tasks, emotional support, and medical needs. Key signs to watch for include mobility challenges, memory lapses, and difficulty performing routine activities. Identifying these early ensures your loved one receives the right care at the right time.</p>
  </section>
  
    
  <!-- average rating  -->
<%
double avgHomeCare = 0;
double avgMealSupport = 0;
double avgTransport = 0;
  
  try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // prepare SQL statement once | round avg rating to 1 dp, coalesce to make sure 0 is returned instead of null if there are no values
    String sql = "SELECT COALESCE(ROUND(AVG(rating), 1), 0) AS avg_rating FROM feedbacks WHERE service_id = ?";
    PreparedStatement ps = conn.prepareStatement(sql);

    // Home Care (service_id = 1)
    ps.setInt(1, 1);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) avgHomeCare = rs.getDouble("avg_rating");

    // Meal Support (service_id = 2)
    ps.setInt(1, 2);
    rs = ps.executeQuery();
    if (rs.next()) avgMealSupport = rs.getDouble("avg_rating");

    // Transportation (service_id = 3)
    ps.setInt(1, 3);
    rs = ps.executeQuery();
    if (rs.next()) avgTransport = rs.getDouble("avg_rating");

    conn.close();
} catch (Exception e) {
    out.println("Error loading average ratings: " + e);
}
%>

  <!-- Services Offered Section -->
  <section class="about">
    <h2>Our Elderly Care Services</h2>
    <div class="features">
      <div class="feature-box">
        <h3>Home Care</h3>
		<p class="avg-rating">★ Average Rating: <%= avgHomeCare %> / 5.0</p>
        <p>Our home care service brings trained caregivers directly to your loved one’s home. Services include:</p>
        <ul>
          <li>Assistance with daily personal activities such as bathing, dressing, grooming, and toileting.</li>
          <li>Medication management and reminders to ensure treatment schedules are followed.</li>
          <li>Companionship and emotional support to reduce feelings of loneliness and social isolation.</li>
          <li>Light housekeeping, laundry, and home safety checks to create a secure living environment.</li>
          <li>Specialized care for seniors with conditions like dementia, mobility issues, or chronic illnesses.</li>
        </ul>
      </div>

      <div class="feature-box">
        <h3>Meal Support</h3>
		<p class="avg-rating">★ Average Rating: <%= avgMealSupport %> / 5.0</p>
        <p>Proper nutrition is essential for healthy aging, and our meal support services are designed to make mealtime stress-free and nourishing:</p>
        <ul>
          <li>Home-delivered meals prepared with senior-friendly recipes and balanced nutrition.</li>
          <li>Customization for dietary restrictions, allergies, or health conditions such as diabetes or hypertension.</li>
          <li>Assistance with meal preparation, portioning, and feeding if required.</li>
          <li>Support in creating meal plans that maintain energy, hydration, and overall health.</li>
        </ul>
      </div>

      <div class="feature-box">
        <h3>Transportation Assistance</h3>
        <p class="avg-rating">★ Average Rating: <%= avgTransport %> / 5.0</p>
        <p>Transportation is a critical part of maintaining independence, attending medical appointments, and staying socially connected. Our transportation service includes:</p>
        <ul>
          <li>Safe and comfortable rides for hospital visits, therapy sessions, or check-ups.</li>
          <li>Escort services to help seniors navigate public areas, clinics, and appointments.</li>
          <li>Reliable transport for social activities, community programs, or family gatherings.</li>
          <li>Flexible scheduling to match the senior’s routine and preferences.</li>
        </ul>
      </div>
    </div>
  </section>

  <!--landing page details, what we offer -->
  <section class="about">
    <h2>Why Choose Silver 47?</h2>
    <div class="features">
      <div class="feature-box">
        <h3>Professional Caregivers</h3>
        <p>Our caregivers are experienced and trained to provide compassionate, professional care tailored to your needs.</p>
      </div>
      <div class="feature-box">
        <h3>Flexible Plans</h3>
        <p>From hourly assistance to full-time support, we offer flexible plans that fit every family’s lifestyle.</p>
      </div>
      <div class="feature-box">
        <h3>Trusted Support</h3>
        <p>We are dedicated to maintaining the comfort, safety, and dignity of your loved ones through quality care.</p>
      </div>
    </div>
  </section>

  <div class="button-container">
      <a href="serviceDetails.jsp" class="btn-outline">More Information</a>
  </div>

</main>
<%@ include file="footer.jsp" %>

<!--  For carousel  -->
<script>
let slideIndex = 1;
showSlides(slideIndex);

function plusSlides(n) {
  showSlides(slideIndex += n);
}

function currentSlide(n) {
  showSlides(slideIndex = n);
}

function showSlides(n) {
  let i;
  let slides = document.getElementsByClassName("carousel-slide");
  let dots = document.getElementsByClassName("dot");

  if (n > slides.length) { slideIndex = 1 }
  if (n < 1) { slideIndex = slides.length }

  for (i = 0; i < slides.length; i++) {
    slides[i].style.display = "none";
  }

  for (i = 0; i < dots.length; i++) {
    dots[i].className = dots[i].className.replace(" active", "");
  }

  slides[slideIndex-1].style.display = "block";
  dots[slideIndex-1].className += " active";
}

setInterval(() => { plusSlides(1); }, 5000);
</script>

</body>
</html>
