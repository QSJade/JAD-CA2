package model;

import java.io.Serializable;

public class BookingCartItem implements Serializable {
    private int serviceId;
    private int packageId;
    private String serviceName;
    private String packageName;
    private String startDate;
    private String endDate;
    private String notes;
    private String address;
    private double pricePerDay;

    public BookingCartItem(int serviceId, int packageId, String serviceName, String packageName,
                           String startDate, String endDate, String notes, String address, double pricePerDay) {
        this.serviceId = serviceId;
        this.packageId = packageId;
        this.serviceName = serviceName;
        this.packageName = packageName;
        this.startDate = startDate;
        this.endDate = endDate;
        this.notes = notes;
        this.address = address;
        this.pricePerDay = pricePerDay;
    }

    // Getters and setters
    public int getServiceId() { return serviceId; }
    public int getPackageId() { return packageId; }
    public String getServiceName() { return serviceName; }
    public String getPackageName() { return packageName; }
    public String getStartDate() { return startDate; }
    public String getEndDate() { return endDate; }
    public String getNotes() { return notes; }
    public String getAddress() { return address; }
    public double getPricePerDay() { return pricePerDay; }

    public void setServiceId(int serviceId) {this.serviceId = serviceId;}
    public void setServiceName(String serviceName) {this.serviceName = serviceName;}
    public void setPackageId(int packageId) {this.packageId = packageId;}
    public void setPackageName(String packageName) {this.packageName = packageName;}
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public void setNotes(String notes) { this.notes = notes; }
    public void setAddress(String address) { this.address = address; }
    public void setPricePerDay(double pricePerDay) { this.pricePerDay = pricePerDay; }
}
