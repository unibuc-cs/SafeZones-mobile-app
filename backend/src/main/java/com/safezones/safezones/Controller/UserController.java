package com.safezones.safezones.Controller;

import com.safezones.safezones.Dto.UserRequest;
import com.safezones.safezones.Model.User;
import com.safezones.safezones.Repository.UserRepository;
import jakarta.transaction.Transactional;
import org.apache.coyote.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping(path="/users")
public class UserController {
    @Autowired
    private UserRepository userRepository;

    @PostMapping(path="/add")
    public @ResponseBody String addNewUser (@RequestParam(name="name") String name,
                                            @RequestParam(name="email") String email,
                                            @RequestParam(name="id") String id) {

        User user = new User();
        user.setId(id);
        user.setUsername(name);
        user.setEmail(email);
        user.setEmailVerified(false);
        user.setLevel(1);
        user.setRewardPoints(0);
        user.setRegisterDate(new Date());
        userRepository.save(user);
        return "Saved";
    }

    @PutMapping(path = "/update-email-verified/{userId}")
    public ResponseEntity<String> updateEmailVerified(@PathVariable String userId) {
        Optional<User> userOptional = userRepository.findById(userId);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setEmailVerified(true);
            userRepository.save(user);

            return ResponseEntity.ok("Email verification status updated successfully");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
    }


    @GetMapping(path="/all")
    public @ResponseBody List<UserRequest> getAllUsers() {
        List<User> users = (List<User>) userRepository.findAll();
        return users.stream()
                .map(user -> new UserRequest(
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getEmailVerified(),
                        user.getRewardPoints(),
                        user.getLevel(),
                        user.getRegisterDate(),
                        user.getProfileImage()
                ))
                .collect(Collectors.toList());
    }

    @GetMapping(path="/{id}")
    public ResponseEntity<String> getUserById(@PathVariable String id) {

        Optional<User> userOptional = userRepository.findById(id);

        return userOptional.map(user -> ResponseEntity.ok(user.getUsername())).orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body(null));
    }

    @GetMapping(path="/level/{id}")
    public ResponseEntity<?> getUserLevel(@PathVariable String id) {

        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isPresent()) {
            return ResponseEntity.ok(userOptional.get().getLevel());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @GetMapping(path="/mail/{id}")
    public ResponseEntity<?> getUserEmail(@PathVariable String id) {

        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isPresent()) {
            return ResponseEntity.ok(userOptional.get().getEmail());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @PostMapping(path = "/update-profile-image/{userId}")
    public void updateProfileImage(@PathVariable String userId, @RequestParam(name="imagePath") String path) {
        Optional<User> userOptional = userRepository.findById(userId);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setProfileImage(path);
            userRepository.save(user);
        }
    }
    @GetMapping(path = "/get-profile-image/{userId}")
    public ResponseEntity<String> getProfileImage(@PathVariable String userId) {
        Optional<User> userOptional = userRepository.findById(userId);

        return userOptional.map(user -> ResponseEntity.ok(user.getProfileImage())).orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body(null));
    }

    @GetMapping(path="/points/{id}")
    public ResponseEntity<?> getUserPoints(@PathVariable String id) {

        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isPresent()) {
            return ResponseEntity.ok(userOptional.get().getRewardPoints());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @PutMapping(path="/incrementPoints/{id}")
    @Transactional
    public ResponseEntity<String> incrementRewardPoints(@PathVariable String id) {

        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setRewardPoints(user.getRewardPoints() + 1);
            switch (user.getLevel()){
                case 1: {
                    if (user.getRewardPoints() == 10){
                        user.setRewardPoints(0);
                        user.setLevel(2);
                    }
                }
                case 2: {
                    if (user.getRewardPoints() == 20){
                        user.setRewardPoints(0);
                        user.setLevel(3);
                    }
                }
                case 3: {
                    if (user.getRewardPoints() == 30){
                        user.setRewardPoints(0);
                        user.setLevel(4);
                    }
                }
                case 4: {
                    if (user.getRewardPoints() == 40){
                        user.setRewardPoints(0);
                        user.setLevel(5);
                    }
                }
            }
            userRepository.save(user);

            return ResponseEntity.ok("Points incremented by 1");

        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
    }

    @PostMapping(path="/contacts/add-contact/{userId}/{contactId}")
    @Transactional
    public ResponseEntity<String> addContact(@PathVariable String userId, @PathVariable String contactId) {
        Optional<User> userOptional = userRepository.findById(userId);
        Optional<User> contactOptional = userRepository.findById(contactId);

        if (userOptional.isPresent() && contactOptional.isPresent()) {
            User user = userOptional.get();
            User contact = contactOptional.get();

            if (!user.getContacts().contains(contact)) {
                user.getContacts().add(contact);
                userRepository.save(user);
                return ResponseEntity.ok("Contact successfully added!");
            }
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User has already added this contact");
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("One of users not found.");
    }

    @GetMapping("/contacts/added-contacts/{userId}")
    public ResponseEntity<List<Map<String, String>>> getAllContactsByUserId(@PathVariable String userId) {
        Optional<User> userOptional = userRepository.findById(userId);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            // Prepare the list of contacts
            List<Map<String, String>> contacts = user.getContacts().stream()
                    .map(contact -> {
                        Map<String, String> contactInfo = new HashMap<>();
                        contactInfo.put("username", contact.getUsername());
                        contactInfo.put("email", contact.getEmail());
                        contactInfo.put("id", contact.getId());
                        return contactInfo;
                    })
                    .collect(Collectors.toList());

            return ResponseEntity.ok(contacts);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    }

    @GetMapping("/contacts/added-by-contacts/{contactId}")
    public ResponseEntity<List<Map<String, String>>> getAllUsersWhoAddedContact(@PathVariable String contactId) {
        Optional<User> contactOptional = userRepository.findById(contactId);

        if (contactOptional.isPresent()) {
            User contact = contactOptional.get();

            // Fetch the list of users who have added this contact
            List<Map<String, String>> usersWhoAddedContact = contact.getAddedBy().stream()
                    .map(user -> {
                        Map<String, String> userInfo = new HashMap<>();
                        userInfo.put("username", user.getUsername());
                        userInfo.put("email", user.getEmail());
                        userInfo.put("id", user.getId());
                        return userInfo;
                    })
                    .collect(Collectors.toList());

            return ResponseEntity.ok(usersWhoAddedContact);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    }

    @PostMapping("/contacts/remove-contact/{userId}/{contactId}")
    @Transactional
    public ResponseEntity<String> removeContact(@PathVariable String userId, @PathVariable String contactId) {
        Optional<User> userOptional = userRepository.findById(userId);
        Optional<User> contactOptional = userRepository.findById(contactId);
        if (userOptional.isEmpty() || contactOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("One of the users could not be found.");
        }
        User user = userOptional.get();
        User contact = contactOptional.get();
        if (!user.getContacts().contains(contact)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("This contact has already been removed.");
        }
        userRepository.deleteContact(userId, contactId);
        return ResponseEntity.ok("Contact removed successfully!");
    }
}