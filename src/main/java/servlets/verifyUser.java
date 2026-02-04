package servlets;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.UserDAO;
import config.DBConnection;

@WebServlet("/verifyUser")
public class verifyUser extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== VerifyUser Servlet Started ===");

        try {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            System.out.println("DEBUG: Email = " + email);

            UserDAO uDatabase = new UserDAO();
            User uBean = uDatabase.validateLogin(email, password);

            if (uBean != null) {
                System.out.println("DEBUG: Login SUCCESS");

                // create session
                HttpSession session = request.getSession(true);
                session.setAttribute("sessCustomerId", uBean.getCustomerId());
                session.setAttribute("sessCustomerName", uBean.getName());
                session.setAttribute("sessCustomerEmail", uBean.getEmail());
                session.setAttribute("sessCustomerAddress", uBean.getAddress());
                session.setAttribute("sessUserRole", uBean.getRole());

                // redirect by role
                if ("admin".equalsIgnoreCase(uBean.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/assignment1/adminService.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/assignment1/serviceDetails.jsp");
                }

            } else {
                System.out.println("DEBUG: Login FAILED");
                response.sendRedirect(request.getContextPath() + "/assignment1/login.jsp?errCode=invalidLogin");
            }

        } catch (Exception e) {
            System.out.println("ERROR in verifyUser servlet");
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/assignment1/login.jsp?errCode=serverError");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // usually login should be POST
        response.sendRedirect(request.getContextPath() + "/assignment1/login.jsp");
    }
}
