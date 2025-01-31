package com.safezones.safezones.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Builder
@Entity
@AllArgsConstructor
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String content;
    private String userId;
    private Long chatId;
    private LocalDateTime timestamp;


    public Message(String content, String userid, Long chatId, LocalDateTime timestamp) {
        this.content = content;
        this.userId = userid;
        this.chatId = chatId;
        this.timestamp = timestamp;
    }
}