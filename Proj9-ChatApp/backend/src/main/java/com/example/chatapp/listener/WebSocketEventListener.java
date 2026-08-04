package com.example.chatapp.listener;

import com.example.chatapp.model.ChatMessage;
import com.example.chatapp.model.MessageType;
import com.example.chatapp.service.UserPresenceService;
import org.slf.Logger;
import org.slf.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Component
public class WebSocketEventListener {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);
    private final SimpMessageSendingOperations messagingTemplate;
    private final UserPresenceService userPresenceService;
    private final DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    public WebSocketEventListener(SimpMessageSendingOperations messagingTemplate, UserPresenceService userPresenceService) {
        this.messagingTemplate = messagingTemplate;
        this.userPresenceService = userPresenceService;
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());

        String username = (String) headerAccessor.getSessionAttributes().get("username");
        String roomId = (String) headerAccessor.getSessionAttributes().get("roomId");

        if (username != null) {
            logger.info("User disconnected: {} from room {}", username, roomId);

            if (roomId == null) roomId = "general";

            userPresenceService.removeUser(roomId, username);

            // Broadcast LEAVE message
            ChatMessage chatMessage = new ChatMessage();
            chatMessage.setType(MessageType.LEAVE);
            chatMessage.setSender(username);
            chatMessage.setTime(LocalTime.now().format(timeFormatter));
            chatMessage.setRoomId(roomId);
            chatMessage.setContent(username + " left the chat");

            String destination = "/topic/room/" + roomId.trim().toLowerCase();
            messagingTemplate.convertAndSend(destination, chatMessage);

            // Broadcast updated active presence
            List<String> users = userPresenceService.getUsersInRoom(roomId);
            ChatMessage presenceMsg = new ChatMessage();
            presenceMsg.setType(MessageType.PRESENCE);
            presenceMsg.setRoomId(roomId);
            presenceMsg.setActiveUsers(users);
            messagingTemplate.convertAndSend(destination, presenceMsg);
        }
    }
}
