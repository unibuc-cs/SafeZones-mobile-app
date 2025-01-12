package com.safezones.safezones.Model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.*;

@Entity
public class Point {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String userId;
    private String latitude;
    private String longitude;
    private String description;
    private String category;
    private String event;
    private Long votes;
    private LocalDateTime timestamp;

    @ManyToMany
    @JoinTable(
            name = "user_point_likes",
            joinColumns = @JoinColumn(name = "id"),
            inverseJoinColumns = @JoinColumn(name = "userId")
    )
    @JsonManagedReference
    private Set<User> likedByUsers = new HashSet<>();

    public Set<User> getLikedByUsers() {
        return likedByUsers;
    }

    public void setLikedByUsers(Set<User> likedByUsers) {
        this.likedByUsers = likedByUsers;
    }

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

    public void setId(Long id) {
        this.id = id;
    }

    public String getLatitude() {
        return latitude;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getLongitude() {
        return longitude;
    }

    public long getId() {
        return id;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
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
