package service;

import model.Booking;
import repository.BookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    // ===== Get all bookings =====
    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    // ===== Get booking by ID =====
    public Booking getBookingById(Integer id) {
        return bookingRepository.findById(id).orElse(null);
    }

    // ===== Get bookings by customer email =====
    public List<Booking> getBookingsByCustomerEmail(String email) {
        return bookingRepository.findByCustomerEmail(email);
    }

    // ===== Create a booking =====
    public Booking createBooking(Booking booking) {
        return bookingRepository.save(booking);
    }

    // ===== Update booking =====
    public Booking updateBooking(Integer id, Booking updated) {
        return bookingRepository.findById(id).map(b -> {
            b.setService(updated.getService());
            b.setCustomerEmail(updated.getCustomerEmail());
            b.setStartDate(updated.getStartDate());
            b.setEndDate(updated.getEndDate());
            b.setPricePerDay(updated.getPricePerDay());
            b.setNotes(updated.getNotes());
            b.setStatus(updated.getStatus());
            b.setServicePackage(updated.getServicePackage());
            b.setServiceAddress(updated.getServiceAddress());
            b.setSubtotal(updated.getSubtotal());
            b.setGst(updated.getGst());
            b.setTotalAmount(updated.getTotalAmount());
            return bookingRepository.save(b);
        }).orElse(null);
    }

    // ===== Delete booking =====
    public boolean deleteBooking(Integer id) {
        if (bookingRepository.existsById(id)) {
            bookingRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
