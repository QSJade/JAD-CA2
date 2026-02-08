package controller;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;

import jakarta.servlet.http.HttpSession;
import model.Booking;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import service.PaymentService;

import java.util.List;
@Controller
@RequestMapping("/stripe")
public class StripeController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/checkout")
    public String checkout(
            HttpSession session
    ) throws StripeException {

        List<Booking> cart =
            (List<Booking>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            return "redirect:/cart";
        }

        Session stripeSession =
            paymentService.createCheckoutSession(
                cart,
                "http://localhost:8080/stripe/success",
                "http://localhost:8080/stripe/cancel"
            );

        return "redirect:" + stripeSession.getUrl();
    }

    @GetMapping("/success")
    public String success(
            @RequestParam("session_id") String sessionId,
            HttpSession session,
            Model model
    ) throws Exception {

        paymentService.verifyAndSave(sessionId, session);  // call service

        model.addAttribute("sessionId", sessionId);
        return "paymentSuccess"; // paymentSuccess.jsp will show confirmation
    }

}
