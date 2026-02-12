package repository;

import model.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Integer> {
    
    List<Invoice> findByUserCustomerId(Integer customerId);
    
    List<Invoice> findByPaymentStatus(String status);
    
    @Query("SELECT i FROM Invoice i WHERE i.invoiceDate BETWEEN :startDate AND :endDate")
    List<Invoice> findByInvoiceDateBetween(@Param("startDate") LocalDateTime startDate, 
                                           @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT i.user.customerId, i.user.name, SUM(i.totalAmount) as totalSpent " +
           "FROM Invoice i WHERE i.paymentStatus = 'paid' " +
           "GROUP BY i.user.customerId, i.user.name " +
           "ORDER BY totalSpent DESC")
    List<Object[]> findTopClientsBySpending();
    
    @Query("SELECT i FROM Invoice i JOIN i.booking b WHERE b.service.serviceId = :serviceId")
    List<Invoice> findInvoicesByServiceId(@Param("serviceId") Integer serviceId);
    
    @Query("SELECT SUM(i.totalAmount) FROM Invoice i WHERE i.paymentStatus = 'paid'")
    Double getTotalRevenue();
    
    @Query("SELECT COUNT(i) FROM Invoice i WHERE i.paymentStatus = 'paid'")
    Long getTotalPaidInvoices();
    
    @Query("SELECT MONTH(i.invoiceDate), YEAR(i.invoiceDate), SUM(i.totalAmount) " +
           "FROM Invoice i WHERE i.paymentStatus = 'paid' " +
           "GROUP BY YEAR(i.invoiceDate), MONTH(i.invoiceDate) " +
           "ORDER BY YEAR(i.invoiceDate) DESC, MONTH(i.invoiceDate) DESC")
    List<Object[]> getMonthlyRevenue();
}