package com.safezones.safezones;

import com.safezones.safezones.Controller.PointController;
import com.safezones.safezones.Dto.PointRequest;
import com.safezones.safezones.Model.Point;
import com.safezones.safezones.Model.User;
import com.safezones.safezones.Repository.PointRepository;
import com.safezones.safezones.Repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PointControllerTest {

    @Mock
    private PointRepository pointRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private PointController pointController;

    private PointRequest pointRequest;
    private Point point;
    private User user;

    @BeforeEach
    void setUp() {
        pointRequest = new PointRequest();
        pointRequest.setLatitude("40.7128");
        pointRequest.setLongitude("-74.0060");
        pointRequest.setDescription("Test Description");
        pointRequest.setCategory("Hard");
        pointRequest.setUserId("user1");
        pointRequest.setEvent("Test Event");

        point = new Point();
        point.setId(1L);
        point.setLatitude("40.7128");
        point.setLongitude("-74.0060");
        point.setDescription("Test Description");
        point.setCategory("Hard");
        point.setUserId("user1");
        point.setEvent("Test Event");
        point.setVotes(0L);
        point.setTimestamp(LocalDateTime.now());

        user = new User();
        user.setUserId("user1");
    }

    @Test
    void addNewPoint_ValidRequest_SavesPoint() {
        String response = pointController.addNewPoint(pointRequest);

        assertEquals("Point added successfully", response);

        ArgumentCaptor<Point> pointCaptor = ArgumentCaptor.forClass(Point.class);
        verify(pointRepository).save(pointCaptor.capture());
        Point savedPoint = pointCaptor.getValue();

        assertEquals(pointRequest.getLatitude(), savedPoint.getLatitude());
        assertEquals(pointRequest.getLongitude(), savedPoint.getLongitude());
        assertEquals(pointRequest.getDescription(), savedPoint.getDescription());
        assertEquals(pointRequest.getCategory(), savedPoint.getCategory());
        assertEquals(pointRequest.getUserId(), savedPoint.getUserId());
        assertEquals(pointRequest.getEvent(), savedPoint.getEvent());
        assertEquals(0L, savedPoint.getVotes());
        assertNotNull(savedPoint.getTimestamp());
    }

    @Test
    void getAllPoints_FiltersCorrectly() {
        LocalDateTime now = LocalDateTime.now();

        Point hardValid = new Point();
        hardValid.setCategory("Hard");
        hardValid.setTimestamp(now.minusHours(23));

        Point hardInvalid = new Point();
        hardInvalid.setCategory("Hard");
        hardInvalid.setTimestamp(now.minusHours(25));

        Point mediumValid = new Point();
        mediumValid.setCategory("Medium");
        mediumValid.setTimestamp(now.minusHours(11));

        Point mediumInvalid = new Point();
        mediumInvalid.setCategory("Medium");
        mediumInvalid.setTimestamp(now.minusHours(13));

        when(pointRepository.findAll()).thenReturn(Arrays.asList(hardValid, hardInvalid, mediumValid, mediumInvalid));

        Iterable<PointRequest> result = pointController.getAllPoints();
        List<PointRequest> resultList = (List<PointRequest>) result;

        assertEquals(2, resultList.size());
        List<String> categories = resultList.stream().map(PointRequest::getCategory).toList();
        assertTrue(categories.contains("Hard"));
        assertTrue(categories.contains("Medium"));
    }

    @Test
    void getPointsByUserId_UserExists_ReturnsPoints() {
        String userId = "user1";
        List<Point> points = Arrays.asList(point, new Point());

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(pointRepository.findByUserId(userId)).thenReturn(points);

        List<Point> result = pointController.getPointsByUserId(userId);

        assertEquals(2, result.size());
        verify(userRepository).findById(userId);
        verify(pointRepository).findByUserId(userId);
    }

    @Test
    void getPointsByUserId_UserNotFound_ThrowsException() {
        String userId = "nonExistentUser";
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> pointController.getPointsByUserId(userId));
    }

    @Test
    void incrementVotes_PointAndUserExist_UserNotLiked_IncrementsVotes() {
        when(pointRepository.findById(1)).thenReturn(Optional.of(point));
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = pointController.incrementVotes(1, "user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Votes incremented successfully to 1", response.getBody());
        assertEquals(1, point.getVotes());
        assertTrue(point.getLikedByUsers().contains(user));
        verify(pointRepository).save(point);
    }

    @Test
    void incrementVotes_UserAlreadyLiked_ReturnsConflict() {
        point.getLikedByUsers().add(user);
        when(pointRepository.findById(1)).thenReturn(Optional.of(point));
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = pointController.incrementVotes(1, "user1");

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertEquals("User has already liked this point", response.getBody());
        assertEquals(0L, point.getVotes());
    }

    @Test
    void incrementVotes_PointNotFound_ReturnsNotFound() {
        when(pointRepository.findById(1)).thenReturn(Optional.empty());

        ResponseEntity<String> response = pointController.incrementVotes(1, "user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("Point or user not found", response.getBody());
    }

    @Test
    void getVotesById_PointExists_ReturnsVotes() {
        when(pointRepository.findById(1)).thenReturn(Optional.of(point));

        ResponseEntity<?> response = pointController.getVotesById(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(0L, response.getBody());
    }

    @Test
    void getVotesById_PointNotFound_ReturnsNotFound() {
        when(pointRepository.findById(1)).thenReturn(Optional.empty());

        ResponseEntity<?> response = pointController.getVotesById(1);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("Point not found", response.getBody());
    }

    @Test
    void pointLikedByUser_UserLiked_ReturnsTrue() {
        point.getLikedByUsers().add(user);
        when(pointRepository.findById(1)).thenReturn(Optional.of(point));
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<Boolean> response = pointController.pointLikedByUser(1, "user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody());
    }

    @Test
    void pointLikedByUser_UserNotLiked_ReturnsFalse() {
        when(pointRepository.findById(1)).thenReturn(Optional.of(point));
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<Boolean> response = pointController.pointLikedByUser(1, "user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertFalse(response.getBody());
    }
}