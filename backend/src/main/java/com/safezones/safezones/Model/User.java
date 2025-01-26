package com.safezones.safezones.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;

import java.util.*;

@Entity
public class User {
    @Id
    private String id;
    private String username;
    private String email;
    private boolean emailVerified;
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

    @ManyToMany
    @JoinTable(
            name = "user_contacts",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "contact_id")
    )
    @JsonManagedReference
    private Set<User> contacts = new HashSet<>();

    @ManyToMany(mappedBy = "contacts")
    @JsonBackReference
    private Set<User> addedBy = new HashSet<>();

    @ManyToMany(mappedBy = "likedByUsers")
    @JsonBackReference
    private Set<Point> likedPoints = new HashSet<>();

    public Set<User> getContacts() {
        return contacts;
    }

    public void setContacts(Set<User> contacts) {
        this.contacts = contacts;
    }

    public Set<User> getAddedBy() {
        return addedBy;
    }

    public void setAddedBy(Set<User> addedBy) {
        this.addedBy = addedBy;
    }


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

    public boolean getEmailVerified() { return this.emailVerified; }

    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

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

