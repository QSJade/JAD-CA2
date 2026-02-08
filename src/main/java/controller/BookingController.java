package controller;

import model.Booking;
import service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @GetMapping
    public List<Booking> getAllBookings() { return bookingService.getAllBookings(); }

    @GetMapping("/{id}")
    public Booking getBooking(@PathVariable Integer id) { return bookingService.getBookingById(id); }

    @PostMapping
    public Booking createBooking(@RequestBody Booking booking) { return bookingService.createBooking(booking); }

    @PutMapping("/{id}")
    public Booking updateBooking(@PathVariable Integer id, @RequestBody Booking updated) {
        return bookingService.updateBooking(id, updated);
    }

    @DeleteMapping("/{id}")
    public boolean deleteBooking(@PathVariable Integer id) { return bookingService.deleteBooking(id); }
}
