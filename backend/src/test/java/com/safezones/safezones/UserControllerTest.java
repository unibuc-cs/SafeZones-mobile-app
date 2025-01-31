package com.safezones.safezones;

import com.safezones.safezones.Controller.UserController;
import com.safezones.safezones.Dto.UserRequest;
import com.safezones.safezones.Model.User;
import com.safezones.safezones.Repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserController userController;

    private User user;
    private User contact;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId("user1");
        user.setUsername("JohnDoe");
        user.setEmail("john@example.com");
        user.setEmailVerified(false);
        user.setRewardPoints(0);
        user.setLevel(1);
        user.setRegisterDate(new Date());

        contact = new User();
        contact.setId("contact1");
        contact.setUsername("JaneDoe");
        contact.setEmail("jane@example.com");
    }

    @Test
    void addNewUser_ValidRequest_SavesUser() {
        String response = userController.addNewUser("JohnDoe", "john@example.com", "user1");

        assertEquals("Saved", response);

        verify(userRepository).save(any(User.class));
    }

    @Test
    void updateEmailVerified_UserExists_UpdatesStatus() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.updateEmailVerified("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Email verification status updated successfully", response.getBody());
        assertTrue(user.getEmailVerified());
        verify(userRepository).save(user);
    }

    @Test
    void updateEmailVerified_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.updateEmailVerified("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("User not found", response.getBody());
    }

    @Test
    void getAllUsers_ReturnsListOfUsers() {
        when(userRepository.findAll()).thenReturn(Arrays.asList(user, contact));

        List<UserRequest> result = userController.getAllUsers();

        assertEquals(2, result.size());
        assertEquals("JohnDoe", result.get(0).getUsername());
        assertEquals("JaneDoe", result.get(1).getUsername());
    }

    @Test
    void getUserById_UserExists_ReturnsUsername() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.getUserById("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("JohnDoe", response.getBody());
    }

    @Test
    void getUserById_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.getUserById("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void getUserLevel_UserExists_ReturnsLevel() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<?> response = userController.getUserLevel("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody());
    }

    @Test
    void getUserLevel_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<?> response = userController.getUserLevel("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void getUserEmail_UserExists_ReturnsEmail() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<?> response = userController.getUserEmail("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("john@example.com", response.getBody());
    }

    @Test
    void getUserEmail_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<?> response = userController.getUserEmail("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void updateProfileImage_UserExists_UpdatesImage() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        userController.updateProfileImage("user1", "path/to/image");

        assertEquals("path/to/image", user.getProfileImage());
        verify(userRepository).save(user);
    }

    @Test
    void getProfileImage_UserExists_ReturnsImagePath() {
        user.setProfileImage("path/to/image");
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.getProfileImage("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("path/to/image", response.getBody());
    }

    @Test
    void getProfileImage_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.getProfileImage("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void getUserPoints_UserExists_ReturnsPoints() {
        user.setRewardPoints(10);
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<?> response = userController.getUserPoints("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(10, response.getBody());
    }

    @Test
    void getUserPoints_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<?> response = userController.getUserPoints("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void incrementRewardPoints_UserExists_IncrementsPoints() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.incrementRewardPoints("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Points incremented by 1", response.getBody());
        assertEquals(1, user.getRewardPoints());
        verify(userRepository).save(user);
    }

    @Test
    void incrementRewardPoints_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.incrementRewardPoints("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("User not found", response.getBody());
    }

    @Test
    void addContact_UserAndContactExist_AddsContact() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));
        when(userRepository.findById("contact1")).thenReturn(Optional.of(contact));

        ResponseEntity<String> response = userController.addContact("user1", "contact1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Contact successfully added!", response.getBody());
        assertTrue(user.getContacts().contains(contact));
        verify(userRepository).save(user);
    }

    @Test
    void addContact_ContactAlreadyAdded_ReturnsConflict() {
        user.getContacts().add(contact);
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));
        when(userRepository.findById("contact1")).thenReturn(Optional.of(contact));

        ResponseEntity<String> response = userController.addContact("user1", "contact1");

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertEquals("User has already added this contact", response.getBody());
    }

    @Test
    void addContact_UserOrContactNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.addContact("user1", "contact1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("One of users not found.", response.getBody());
    }

    @Test
    void getAllAddedByUserId_UserExists_ReturnsContacts() {
        user.getAddedBy().add(contact);
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<List<Map<String, String>>> response = userController.getAllContactsByUserId("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("JaneDoe", response.getBody().get(0).get("username"));
    }

    @Test
    void getAllContactsByUserId_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<List<Map<String, String>>> response = userController.getAllContactsByUserId("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void getAllUsersWhoAddedContact_ContactExists_ReturnsUsers() {
        contact.getAddedBy().add(user);
        when(userRepository.findById("contact1")).thenReturn(Optional.of(contact));

        ResponseEntity<List<Map<String, String>>> response = userController.getAllUsersWhoAddedContact("contact1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("JohnDoe", response.getBody().get(0).get("username"));
    }

    @Test
    void getAllUsersWhoAddedContact_ContactNotFound_ReturnsNotFound() {
        when(userRepository.findById("contact1")).thenReturn(Optional.empty());

        ResponseEntity<List<Map<String, String>>> response = userController.getAllUsersWhoAddedContact("contact1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }

    @Test
    void removeContact_UserAndContactExist_RemovesContact() {
        user.getContacts().add(contact);
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));
        when(userRepository.findById("contact1")).thenReturn(Optional.of(contact));

        ResponseEntity<String> response = userController.removeContact("user1", "contact1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Contact removed successfully!", response.getBody());
        assertFalse(user.getAddedBy().contains(contact));
        verify(userRepository).deleteContact("user1", "contact1");
    }

    @Test
    void removeContact_ContactNotAdded_ReturnsConflict() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));
        when(userRepository.findById("contact1")).thenReturn(Optional.of(contact));

        ResponseEntity<String> response = userController.removeContact("user1", "contact1");

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertEquals("This contact has already been removed.", response.getBody());
    }

    @Test
    void removeContact_UserOrContactNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.removeContact("user1", "contact1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("One of the users could not be found.", response.getBody());
    }

    @Test
    void updateLocation_UserExists_UpdatesLocation() {
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.updateLocation("user1", 40.7128, -74.0060);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Location succesfully updated", response.getBody());
        assertEquals(40.7128, user.getLatitude());
        assertEquals(-74.0060, user.getLongitude());
        verify(userRepository).save(user);
    }

    @Test
    void updateLocation_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.updateLocation("user1", 40.7128, -74.0060);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("User not found", response.getBody());
    }

    @Test
    void getLocations_UserExists_ReturnsLocations() {
        contact.setLatitude(40.7128);
        contact.setLongitude(-74.0060);
        user.getAddedBy().add(contact);
        when(userRepository.findById("user1")).thenReturn(Optional.of(user));

        ResponseEntity<List<Map<String, String>>> response = userController.getLocations("user1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("40.7128", response.getBody().get(0).get("latitude"));
        assertEquals("-74.006", response.getBody().get(0).get("longitude"));
    }

    @Test
    void getLocations_UserNotFound_ReturnsNotFound() {
        when(userRepository.findById("user1")).thenReturn(Optional.empty());

        ResponseEntity<List<Map<String, String>>> response = userController.getLocations("user1");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNull(response.getBody());
    }
}