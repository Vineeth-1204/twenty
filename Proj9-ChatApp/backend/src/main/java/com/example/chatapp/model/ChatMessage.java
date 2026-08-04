package com.example.chatapp.model;

import java.util.List;

public class ChatMessage {
    private MessageType type;
    private String content;
    private String sender;
    private String time;
    private String roomId;
    private List<String> activeUsers;

    public ChatMessage() {
    }

    public ChatMessage(MessageType type, String content, String sender, String time, String roomId) {
        this.type = type;
        this.content = content;
        this.sender = sender;
        this.time = time;
        this.roomId = roomId;
    }

    public MessageType getType() {
        return type;
    }

    public void setType(MessageType type) {
        this.type = type;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public List<String> getActiveUsers() {
        return activeUsers;
    }

    public void setActiveUsers(List<String> activeUsers) {
        this.activeUsers = activeUsers;
    }
}
