package com.safezones.safezones.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.*;

@Entity
@Getter
@Setter
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
    private Double latitude;
    private Double longitude;

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


    public boolean getEmailVerified() { return this.emailVerified; }
    public void setUserId(String id) { this.id = id; }

}

