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
        return bookings;
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    public Booking getBookingById(Integer id) {
        Booking booking = bookingRepository.findById(id).orElse(null);
        if (booking != null) {
            if (booking.getSubtotal() == null) booking.setSubtotal(0.0);
            if (booking.getGst() == null) booking.setGst(0.0);
            if (booking.getTotalAmount() == null) booking.setTotalAmount(0.0);
        }
        return booking;
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
            if ("pending".equalsIgnoreCase(booking.getStatus())) {
                booking.setStatus("confirmed");
                bookingRepository.save(booking);
                return true;
            }
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
        // Update confirmed bookings that have ended to 'completed' status
        String sql = "UPDATE bookings SET status='completed' WHERE status='confirmed' AND end_date < CURRENT_DATE";
        // Use entity manager or repository to execute native query
        List<Booking> endedBookings = bookingRepository.findByStatusAndEndDateBefore("confirmed", LocalDate.now());
        for (Booking booking : endedBookings) {
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
    
    // ===== ADDED METHODS FOR ADMIN SALES =====
    
    public List<Booking> getBookingsByDateRange(LocalDate startDate, LocalDate endDate) {
        return bookingRepository.findByStartDateBetween(startDate, endDate);
    }
    
    public List<Booking> getBookingsByServiceId(Integer serviceId) {
        return bookingRepository.findByServiceServiceId(serviceId);
    }
}