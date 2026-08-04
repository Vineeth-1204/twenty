package com.example.chatapp.controller;

import com.example.chatapp.model.ChatMessage;
import com.example.chatapp.model.MessageType;
import com.example.chatapp.service.UserPresenceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;
    private final UserPresenceService userPresenceService;
    private final DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    public ChatController(SimpMessagingTemplate messagingTemplate, UserPresenceService userPresenceService) {
        this.messagingTemplate = messagingTemplate;
        this.userPresenceService = userPresenceService;
    }

    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload ChatMessage chatMessage) {
        if (chatMessage.getContent() == null || chatMessage.getContent().trim().isEmpty()) {
            return; // Ignore empty messages
        }
        if (chatMessage.getTime() == null || chatMessage.getTime().isEmpty()) {
            chatMessage.setTime(LocalTime.now().format(timeFormatter));
        }
        String destination = getRoomDestination(chatMessage.getRoomId());
        messagingTemplate.convertAndSend(destination, chatMessage);
    }

    @MessageMapping("/chat.addUser")
    public void addUser(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor) {
        String username = chatMessage.getSender();
        String roomId = chatMessage.getRoomId() != null ? chatMessage.getRoomId() : "general";

        if (username == null || username.trim().isEmpty()) {
            return;
        }

        // Add username and roomId to WebSocket session
        headerAccessor.getSessionAttributes().put("username", username);
        headerAccessor.getSessionAttributes().put("roomId", roomId);

        // Update presence service
        userPresenceService.addUser(roomId, username);

        // Broadcast JOIN message
        chatMessage.setTime(LocalTime.now().format(timeFormatter));
        chatMessage.setRoomId(roomId);
        String destination = getRoomDestination(roomId);
        messagingTemplate.convertAndSend(destination, chatMessage);

        // Broadcast presence update
        broadcastPresenceUpdate(roomId);
    }

    @MessageMapping("/chat.typing")
    public void sendTypingSignal(@Payload ChatMessage chatMessage) {
        String destination = getRoomDestination(chatMessage.getRoomId());
        messagingTemplate.convertAndSend(destination, chatMessage);
    }

    private void broadcastPresenceUpdate(String roomId) {
        List<String> users = userPresenceService.getUsersInRoom(roomId);
        ChatMessage presenceMsg = new ChatMessage();
        presenceMsg.setType(MessageType.PRESENCE);
        presenceMsg.setRoomId(roomId);
        presenceMsg.setActiveUsers(users);
        messagingTemplate.convertAndSend(getRoomDestination(roomId), presenceMsg);
    }

    private String getRoomDestination(String roomId) {
        if (roomId == null || roomId.trim().isEmpty()) {
            roomId = "general";
        }
        return "/topic/room/" + roomId.trim().toLowerCase();
    }
}
