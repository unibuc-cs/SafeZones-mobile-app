package com.safezones.safezones.Dto;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;

import java.util.Date;

@Getter
@Setter
public class UserRequest {
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

    public UserRequest(String id, String username, String email, boolean emailVerified, int rewardPoints, int level, Date registerDate, String profileImage, Double latitude, Double longitude) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.emailVerified = emailVerified;
        this.rewardPoints = rewardPoints;
        this.level = level;
        this.registerDate = registerDate;
        this.profileImage = profileImage;
        this.latitude = latitude;
        this.longitude = longitude;
    }

}