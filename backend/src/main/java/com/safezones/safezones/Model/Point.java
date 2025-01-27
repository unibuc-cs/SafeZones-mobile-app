package com.safezones.safezones.Model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.*;

@Entity
@Getter
@Setter
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

}
