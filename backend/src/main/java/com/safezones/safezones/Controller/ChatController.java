package com.safezones.safezones.Controller;

import com.safezones.safezones.Dto.MessageDTO;
import com.safezones.safezones.Dto.PointRequest;
import com.safezones.safezones.Model.Message;
import com.safezones.safezones.Model.MessageType;
import com.safezones.safezones.Model.Point;
import com.safezones.safezones.Model.User;
import com.safezones.safezones.Repository.MessageRepository;
import com.safezones.safezones.Repository.PointRepository;
import com.safezones.safezones.Repository.UserRepository;
import com.safezones.safezones.Service.WebSocketSessionManager;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/chat")
public class ChatController {

    private final WebSocketSessionManager sessionManager;
    @Autowired
    private MessageRepository chatRepository;

    @Autowired
    private UserRepository userRepository;

    @PostMapping(path = "/add")
    public @ResponseBody String addNewMessage(@RequestBody MessageDTO messageDto) {
        Message newMessage = new Message(
                messageDto.getContent(),
                messageDto.getUserId(),
                messageDto.getChatId(),
                LocalDateTime.now()
                //MessageType.CHAT
        );
        chatRepository.save(newMessage);
        return "Message added successfully";
    }

    @GetMapping(path = "/get/{chatId}")
    public ResponseEntity<List<Map<String, String>>> getMessages(@PathVariable long chatId) {
        List<Message> messages = chatRepository.findMessagesByChatId(chatId);


        List<Map<String, String>> responseMessages = new ArrayList<>();
        for (Message message : messages) {
            Map<String, String> messageWithUsername = new HashMap<>();
            messageWithUsername.put("content", message.getContent());

            User user = userRepository.findById(message.getUserId()).orElseThrow(() -> new RuntimeException("User not found"));
            messageWithUsername.put("username", user.getUsername());
            messageWithUsername.put("timestamp", message.getTimestamp().toString());

            responseMessages.add(messageWithUsername);
        }

        return ResponseEntity.ok(responseMessages);
    }
}