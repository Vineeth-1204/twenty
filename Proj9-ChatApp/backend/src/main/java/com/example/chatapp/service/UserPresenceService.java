package com.example.chatapp.service;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserPresenceService {

    // roomId -> Set of usernames
    private final Map<String, Set<String>> roomUsers = new ConcurrentHashMap<>();

    public void addUser(String roomId, String username) {
        if (roomId == null || username == null) return;
        roomUsers.computeIfAbsent(roomId, k -> ConcurrentHashMap.newKeySet()).add(username);
    }

    public void removeUser(String roomId, String username) {
        if (roomId == null || username == null) return;
        Set<String> users = roomUsers.get(roomId);
        if (users != null) {
            users.remove(username);
        }
    }

    public List<String> getUsersInRoom(String roomId) {
        Set<String> users = roomUsers.get(roomId);
        if (users == null) {
            return Collections.emptyList();
        }
        return new ArrayList<>(users);
    }
}
