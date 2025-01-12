package com.safezones.safezones.Config;

import com.safezones.safezones.Model.ChatMessage;
import com.safezones.safezones.Model.MessageType;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketEventListener {

    private final SimpMessageSendingOperations messageTemplate;

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String username = (String) headerAccessor.getSessionAttributes().get("username");
        Long chatId = (Long) headerAccessor.getSessionAttributes().get("chatId");

        if (username != null && chatId != null) {
            log.info("User disconnected: {}", username);
            var chatMessage = ChatMessage.builder()
                    .type(MessageType.LEAVE)
                    .chatId(chatId)
                    .sender(username)
                    .build();

            // Format the channel address correctly
            messageTemplate.convertAndSend(String.format("/topic/public/%d", chatId), chatMessage);
        }
    }
}
