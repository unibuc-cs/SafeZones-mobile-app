package com.safezones.safezones.Dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class PointRequest {
    private String latitude;
    private String longitude;
    private String description;
    private String category;
    private String event;
    private Long votes;
    private LocalDateTime timestamp;
    private String userId;
    private Long id;

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

    public PointRequest() {

    }

    public PointRequest(Long id, String userId, String latitude, String longitude, LocalDateTime timestamp, String description, String category, String event, Long votes) {
        this.id = id;
        this.latitude = latitude;
        this.longitude = longitude;
        this.description = description;
        this.category = category;
        this.timestamp = timestamp;
        this.userId = userId;
        this.event = event;
        this.votes = votes;
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
