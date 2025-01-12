package com.safezones.safezones.Dto;

public class PointRequest {
    private String latitude;
    private String longitude;
    private String description;
    private String category;
    private String event;
    private Long votes;
    // private Date timestamp;
    private String userId;

    public PointRequest(String latitude, String longitude, String description, String category, String userId, String event) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.description = description;
        this.category = category;
        //this.timestamp = timestamp;
        this.userId = userId;
        this.event = event;
        this.votes = 0L;
    }

    // Getters și Setters
    public Long getVotes() {
        return votes;
    }

    public void setVotes(Long votes) {
        this.votes = votes;
    }

    public String getEvent() {
        return event;
    }

    public void setEvent(String event) {
        this.event = event;
    }

    public String getLatitude() {
        return latitude;
    }


    public void setCategory(String category) {
        this.category = category;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }


    public String getCategory() {
        return category;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
