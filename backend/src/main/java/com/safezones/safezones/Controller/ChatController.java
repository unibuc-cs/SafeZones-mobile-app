package com.safezones.safezones.Controller;

import com.safezones.safezones.Model.ChatMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.*;
import org.springframework.stereotype.Controller;

@Controller
@Slf4j
public class ChatController {

    @MessageMapping("/chat/{id}")
    @SendTo("/topic/public/{id}")
    public ChatMessage sendMessage(
            @Payload ChatMessage chatMessage
    ) {
        return chatMessage;
    }

    @MessageMapping("/chat/addUser/{id}")
    @SendTo("/topic/public/{id}")
    public ChatMessage addUser(
            @Payload ChatMessage chatMessage,
            SimpMessageHeaderAccessor headerAccessor) {

        // Verifică dacă chatId și username sunt deja setate corect
        if (headerAccessor.getSessionAttributes().containsKey("chatId")) {
            log.info("User already added to chat: {}", chatMessage.getSender());
        } else {
            // Adăugăm utilizatorul la sesiune
            headerAccessor.getSessionAttributes().put("username", chatMessage.getSender());
            headerAccessor.getSessionAttributes().put("chatId", chatMessage.getChatId());
        }
        return chatMessage;
    }
}


