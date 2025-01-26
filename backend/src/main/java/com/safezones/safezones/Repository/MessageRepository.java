package com.safezones.safezones.Repository;

import com.safezones.safezones.Model.Message;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface MessageRepository extends CrudRepository<Message, Long> {
    List<Message> findMessagesByChatId(Long chatId);
}