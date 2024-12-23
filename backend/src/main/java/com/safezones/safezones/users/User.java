package com.safezones.safezones.users;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.safezones.safezones.points.Point;
import jakarta.persistence.*;

import java.util.*;

@Entity
public class User {
    @Id
    private String id;
    private String username;
    private String email;
    private int rewardPoints;
    private int level;
    private Date registerDate;
    private String profileImage;

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    @ManyToMany(mappedBy = "likedByUsers")
    @JsonBackReference
    private Set<Point> likedPoints = new HashSet<>();

    public Set<Point> getLikedPoints() {
        return likedPoints;
    }

    public void setLikedPoints(Set<Point> likedPoints) {
        this.likedPoints = likedPoints;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getRewardPoints() {
        return rewardPoints;
    }

    public void setRewardPoints(int rewardPoints) {
        this.rewardPoints = rewardPoints;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public Date getRegisterDate() {
        return registerDate;
    }

    public void setRegisterDate(Date registerDate) {
        this.registerDate = registerDate;
    }
}

