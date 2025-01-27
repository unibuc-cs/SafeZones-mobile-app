package com.safezones.safezones.Dto;

import com.safezones.safezones.Model.MessageType;
import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class MessageDTO {
    private String content;
    private String userId;
    private Long chatId;
}