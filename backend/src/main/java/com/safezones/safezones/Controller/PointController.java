package com.safezones.safezones.Controller;

import com.safezones.safezones.Model.Point;
import com.safezones.safezones.Repository.PointRepository;
import com.safezones.safezones.Repository.UserRepository;
import com.safezones.safezones.Dto.PointRequest;
import com.safezones.safezones.Model.User;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;


import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping(path = "/points")
public class PointController {
    @Autowired
    private PointRepository pointRepository;
    @Autowired
    private UserRepository userRepository;

    @PostMapping(path = "/add")
    public @ResponseBody String addNewPoint(@RequestBody PointRequest pointRequest) {
        Point point = new Point();
        point.setLatitude(pointRequest.getLatitude());
        point.setLongitude(pointRequest.getLongitude());
        point.setDescription(pointRequest.getDescription());
        point.setCategory(pointRequest.getCategory());
        point.setTimestamp(LocalDateTime.now());
        point.setUserId(pointRequest.getUserId());
        point.setEvent(pointRequest.getEvent());
        point.setVotes(pointRequest.getVotes());
        pointRepository.save(point);
        System.out.println(point.getVotes());
        return "Point added successfully";
    }

    @GetMapping(path = "/all")
    public @ResponseBody Iterable<Point> getAllPoints() {
        Iterable<Point> allPoints = pointRepository.findAll();
        LocalDateTime currentTime = LocalDateTime.now();

        List<Point> filteredPoints = new ArrayList<>();

        for (Point point : allPoints) {

            LocalDateTime placementTime = point.getTimestamp();

            if (point.getCategory().equals("Hard")) {
                if (placementTime.plusHours(24).isAfter(currentTime)) {
                    filteredPoints.add(point);
                }
            } else if (point.getCategory().equals("Medium")) {
                if (placementTime.plusHours(12).isAfter(currentTime)) {
                    filteredPoints.add(point);
                }
            } else {
                filteredPoints.add(point);
            }
        }

        return filteredPoints;
    }


    @GetMapping(path = "/{id}")
    public @ResponseBody List<Point> getPointsByUserId(@PathVariable String id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return pointRepository.findByUserId(id);
    }

    @PostMapping(path = "/incrementVotes/{id}/{userId}")
    @Transactional
    public ResponseEntity<String> incrementVotes(@PathVariable int id, @PathVariable String userId) {

        Optional<Point> pointOptional = pointRepository.findById(id);

        Optional<User> userOptional = userRepository.findById(userId);

        if (pointOptional.isPresent() && userOptional.isPresent()) {
            Point point = pointOptional.get();
            User user = userOptional.get();

            if (!point.getLikedByUsers().contains(user)) {
                point.getLikedByUsers().add(user);
                point.setVotes(point.getVotes() + 1);
                pointRepository.save(point);
                return ResponseEntity.ok("Votes incremented successfully to " + point.getVotes());
            } else {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("User has already liked this point");
            }
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Point or user not found");
        }
    }


    @GetMapping(path = "/votes/{id}")
    public ResponseEntity<?> getVotesById(@PathVariable int id) {

        Optional<Point> pointOptional = pointRepository.findById(id);

        if (pointOptional.isPresent()) {
            Point point = pointOptional.get();
            return ResponseEntity.ok(point.getVotes());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Point not found");
        }
    }

    @GetMapping(path = "/liked-by/{id}/{userId}")
    public ResponseEntity<Boolean> pointLikedByUser(@PathVariable int id, @PathVariable String userId) {
        Optional<Point> pointOptional = pointRepository.findById(id);

        Optional<User> userOptional = userRepository.findById(userId);

        if (pointOptional.isPresent() && userOptional.isPresent()) {
            Point point = pointOptional.get();
            User user = userOptional.get();

            return ResponseEntity.ok(point.getLikedByUsers().contains(user));
        }
        return (ResponseEntity<Boolean>) ResponseEntity.status(HttpStatus.NOT_FOUND);
    }
}

