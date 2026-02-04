package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
 
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.GenericType;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.servlet.RequestDispatcher;
import dbaccess.User;

@WebServlet("/GetUserListServlet")
public class GetUserListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    public GetUserListServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        //response.getWriter().append("Served at: ").append(request.getContextPath());
        //-------------------------------------------------------------------------
        PrintWriter out = response.getWriter();
        Client client = ClientBuilder.newClient();
        String restUrl = "http://localhost:8081/user-ws/getAllUsers";
        WebTarget target = client.target(restUrl);
        Invocation.Builder invocationBuilder = target.request(MediaType.APPLICATION_JSON);
        Response resp = invocationBuilder.get();
        System.out.println("status: " + resp.getStatus());

        //https://stackoverflow.com/questions/18086621/read-response-body-in-jax-rs-client-from-a-post-request
        if (resp.getStatus() == Response.Status.OK.getStatusCode()) {
            System.out.println("success");

            //https://www.logicbig.com/tutorials/java-ee-tutorial/jax-rs/generic-entity.html
            ArrayList<User> al = resp.readEntity(new GenericType<ArrayList<User>>() {}); //needs empty body to preserve generic type
            //System.out.println(al.size());
            request.setAttribute("userArray", al);

            //write to request object for forwarding to target page
            request.setAttribute("userArray", al);
            System.out.print("......requestObj set...forwarding..");
            String url = "/pract8/testweb.jsp";
            RequestDispatcher rd = request.getRequestDispatcher(url);
            rd.forward(request, response);

        } else {
            System.out.println("failed");
            String url = "/pract8/testweb.jsp";
            request.setAttribute("err", "NotFound");
            RequestDispatcher rd = request.getRequestDispatcher(url);
            rd.forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}