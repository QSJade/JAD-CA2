package service;

import model.Booking;
import repository.BookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    /**
     * Get bookings by customer ID - WITHOUT feedback check
     */
    public List<Booking> getBookingsByCustomerId(Integer customerId) {
        List<Booking> bookings = bookingRepository.findByUserCustomerId(customerId);
        // Don't set feedbackExists here - let JSP handle it
        return bookings;
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    public Booking getBookingById(Integer id) {
        return bookingRepository.findById(id).orElse(null);
    }

    @Transactional
    public Booking createBooking(Booking booking) {
        if (booking.getStatus() == null) {
            booking.setStatus("pending");
        }
        if (booking.getCreatedAt() == null) {
            booking.setCreatedAt(LocalDateTime.now());
        }
        return bookingRepository.save(booking);
    }

    @Transactional
    public Booking updateBooking(Integer id, Booking updated) {
        return bookingRepository.findById(id).map(b -> {
            b.setStatus(updated.getStatus());
            b.setNotes(updated.getNotes());
            b.setStartDate(updated.getStartDate());
            b.setEndDate(updated.getEndDate());
            b.setServiceAddress(updated.getServiceAddress());
            return bookingRepository.save(b);
        }).orElse(null);
    }
    
    @Transactional
    public Booking updateBookingStatus(Integer id, String status) {
        return bookingRepository.findById(id).map(b -> {
            b.setStatus(status);
            return bookingRepository.save(b);
        }).orElse(null);
    }
    
    @Transactional
    public boolean cancelBooking(Integer bookingId, Integer customerId) {
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        if (booking != null && booking.getUser().getCustomerId().equals(customerId)) {
            // ONLY allow cancellation of PENDING bookings (not paid)
            if ("pending".equalsIgnoreCase(booking.getStatus())) {
                booking.setStatus("cancelled");
                bookingRepository.save(booking);
                return true;
            }
        }
        return false;
    }
    @Transactional
    public boolean confirmBooking(Integer bookingId, Integer customerId) {
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        if (booking != null && booking.getUser().getCustomerId().equals(customerId)) {
            booking.setStatus("confirmed");
            bookingRepository.save(booking);
            return true;
        }
        return false;
    }
    
    public boolean isBookingCompleted(Integer bookingId, Integer customerId) {
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        return booking != null && 
               booking.getUser().getCustomerId().equals(customerId) &&
               "completed".equals(booking.getStatus()) &&
               booking.getEndDate().isBefore(LocalDate.now());
    }
    
    @Transactional
    public void updateCompletedBookings() {
        List<Booking> confirmedBookings = bookingRepository.findByStatusAndEndDateBefore("confirmed", LocalDate.now());
        for (Booking booking : confirmedBookings) {
            booking.setStatus("completed");
            bookingRepository.save(booking);
        }
    }

    public boolean deleteBooking(Integer id) {
        if (bookingRepository.existsById(id)) {
            bookingRepository.deleteById(id);
            return true;
        }
        return false;
    }
}