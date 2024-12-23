package com.safezones.safezones;

import com.safezones.safezones.users.User;
import com.safezones.safezones.users.UserController;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class UserControllerTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserController userController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    void testAddNewUser() {
        when(userRepository.save(any(User.class))).thenReturn(new User());

        String response = userController.addNewUser("John", "john@example.com", "1");
        assertEquals("Saved", response);
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void testGetAllUsers() {
        when(userRepository.findAll()).thenReturn(Collections.singletonList(new User()));

        Iterable<User> result = userController.getAllUsers();

        assertEquals(1, ((List<User>) result).size());
    }

    @Test
    void testGetUserById() {
        User user = new User();
        user.setUsername("John");
        user.setEmail("john@example.com");
        user.setId("1");

        when(userRepository.findById("1")).thenReturn(Optional.of(user));

        ResponseEntity<String> response = userController.getUserById("1");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("John", response.getBody());
    }


    @Test
    void testGetUserByIdNotFound() {
        when(userRepository.findById("2")).thenReturn(Optional.empty());

        ResponseEntity<String> response = userController.getUserById("2");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals(null, response.getBody());
    }
}
