'use strict';

// DOM Elements
const usernamePage = document.querySelector('#username-page');
const chatPage = document.querySelector('#chat-page');
const usernameForm = document.querySelector('#usernameForm');
const messageForm = document.querySelector('#messageForm');
const messageInput = document.querySelector('#message');
const messageArea = document.querySelector('#messageArea');
const nameInput = document.querySelector('#name');
const nameError = document.querySelector('#name-error');
const roomSelect = document.querySelector('#roomSelect');
const onlineUsersList = document.querySelector('#online-users-list');
const userCountBadge = document.querySelector('#user-count-badge');
const typingIndicator = document.querySelector('#typing-indicator');
const typingText = document.querySelector('#typing-text');

const currentRoomTitle = document.querySelector('#current-room-title');
const currentUserAvatar = document.querySelector('#current-user-avatar');
const currentUserName = document.querySelector('#current-user-name');

const themeToggleBtn = document.querySelector('#theme-toggle');
const emojiToggleBtn = document.querySelector('#emoji-toggle-btn');
const emojiDrawer = document.querySelector('#emoji-drawer');

const toggleSidebarBtn = document.querySelector('#toggle-sidebar-btn');
const closeSidebarBtn = document.querySelector('#close-sidebar-btn');
const sidebar = document.querySelector('#sidebar');
const sidebarOverlay = document.querySelector('#sidebar-overlay');
const roomBtns = document.querySelectorAll('.room-btn');

// State Variables
let stompClient = null;
let username = null;
let currentRoom = 'general';
let activeSubscription = null;
let typingTimeout = null;
let lastTypingBroadcast = 0;

// Colors for user avatars
const avatarColors = [
    '#2563eb', '#7c3aed', '#db2777', '#ca8a04', '#059669', '#d97706', '#dc2626'
];

function getAvatarColor(name) {
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    const index = Math.abs(hash % avatarColors.length);
    return avatarColors[index];
}

// 1. Connect to WebSocket Server
function connect(event) {
    event.preventDefault();
    username = nameInput.value.trim();

    if (!username) {
        nameError.style.display = 'block';
        nameInput.focus();
        return;
    }
    nameError.style.display = 'none';

    currentRoom = roomSelect.value || 'general';

    // Update Profile Info
    currentUserAvatar.textContent = username.charAt(0).toUpperCase();
    currentUserAvatar.style.background = getAvatarColor(username);
    currentUserName.textContent = username;

    // Switch Screens
    usernamePage.classList.add('hidden');
    chatPage.classList.remove('hidden');

    updateRoomUI(currentRoom);

    // Establish WebSocket STOMP Connection over SockJS
    const socketUrl = window.location.origin.includes('http') ? '/ws' : 'http://localhost:8080/ws';
    const socket = new SockJS(socketUrl);
    stompClient = Stomp.over(socket);
    stompClient.debug = null; // Disable debug logs in console

    stompClient.connect({}, onConnected, onError);
}

// 2. STOMP Connection Success Handler
function onConnected() {
    subscribeToRoom(currentRoom);
}

// 3. Subscribe to dynamic room topic
function subscribeToRoom(roomId) {
    if (activeSubscription) {
        activeSubscription.unsubscribe();
    }

    const topicDestination = '/topic/room/' + roomId.toLowerCase();

    activeSubscription = stompClient.subscribe(topicDestination, onMessageReceived);

    // Register user with backend
    stompClient.send("/app/chat.addUser",
        {},
        JSON.stringify({
            sender: username,
            type: 'JOIN',
            roomId: roomId
        })
    );
}

// 4. Connection Error Handler
function onError(error) {
    console.error("Could not connect to WebSocket server", error);
    const errorNotice = document.createElement('div');
    errorNotice.classList.add('system-message');
    errorNotice.textContent = 'Unable to connect to live chat server. Retrying...';
    messageArea.appendChild(errorNotice);
}

// 5. Send Chat Message
function sendMessage(event) {
    event.preventDefault();
    const messageContent = messageInput.value.trim();

    if (messageContent && stompClient) {
        const chatMessage = {
            sender: username,
            content: messageContent,
            type: 'CHAT',
            roomId: currentRoom
        };

        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(chatMessage));
        messageInput.value = '';
        messageInput.focus();
    }
}

// 6. Handle Incoming WebSocket Events
function onMessageReceived(payload) {
    const message = JSON.parse(payload.body);

    if (message.type === 'JOIN') {
        renderSystemMessage(`${message.sender} joined the chat`);
    } else if (message.type === 'LEAVE') {
        renderSystemMessage(`${message.sender} left the chat`);
    } else if (message.type === 'PRESENCE') {
        updateOnlineUsers(message.activeUsers);
    } else if (message.type === 'TYPING') {
        handleTypingNotification(message);
    } else if (message.type === 'CHAT') {
        renderChatMessage(message);
    }
}

// Render System Join/Leave Pills
function renderSystemMessage(text) {
    const sysElement = document.createElement('div');
    sysElement.classList.add('system-message');
    sysElement.textContent = text;
    messageArea.appendChild(sysElement);
    scrollToBottom();
}

// Render User Message Bubbles
function renderChatMessage(message) {
    const isSelf = message.sender === username;

    const groupElement = document.createElement('div');
    groupElement.classList.add('message-group', isSelf ? 'self' : 'other');

    if (!isSelf) {
        const senderElement = document.createElement('div');
        senderElement.classList.add('message-sender');
        senderElement.textContent = message.sender;
        groupElement.appendChild(senderElement);
    }

    const bubbleElement = document.createElement('div');
    bubbleElement.classList.add('message-bubble');
    bubbleElement.textContent = message.content;
    groupElement.appendChild(bubbleElement);

    const timeElement = document.createElement('div');
    timeElement.classList.add('message-time');
    timeElement.textContent = message.time || getCurrentTime();
    groupElement.appendChild(timeElement);

    messageArea.appendChild(groupElement);
    scrollToBottom();
}

// Update Active Online Users Panel
function updateOnlineUsers(usersList) {
    if (!usersList) return;

    onlineUsersList.innerHTML = '';
    userCountBadge.textContent = usersList.length;

    usersList.forEach(user => {
        const li = document.createElement('li');
        li.classList.add('user-item');

        const dot = document.createElement('span');
        dot.classList.add('status-dot', 'online');

        const nameSpan = document.createElement('span');
        nameSpan.textContent = user === username ? `${user} (You)` : user;
        if (user === username) {
            nameSpan.style.fontWeight = '600';
            nameSpan.style.color = 'var(--text-primary)';
        }

        li.appendChild(dot);
        li.appendChild(nameSpan);
        onlineUsersList.appendChild(li);
    });
}

// Typing Notification Handler
function handleTypingNotification(message) {
    if (message.sender === username) return;

    typingText.textContent = `${message.sender} is typing...`;
    typingIndicator.classList.remove('hidden');

    if (typingTimeout) clearTimeout(typingTimeout);
    typingTimeout = setTimeout(() => {
        typingIndicator.classList.add('hidden');
    }, 2000);
}

// Emit Typing Signal (Throttled)
function emitTypingSignal() {
    const now = Date.now();
    if (stompClient && (now - lastTypingBroadcast > 1500)) {
        lastTypingBroadcast = now;
        stompClient.send("/app/chat.typing", {}, JSON.stringify({
            sender: username,
            type: 'TYPING',
            roomId: currentRoom
        }));
    }
}

// Room Switching Logic
function switchRoom(newRoom) {
    if (newRoom === currentRoom) return;

    currentRoom = newRoom;
    updateRoomUI(currentRoom);

    // Clear feed & notify room switch
    messageArea.innerHTML = '';
    renderSystemMessage(`Switched to #${capitalize(currentRoom)} room`);

    // Subscribe to new STOMP channel
    subscribeToRoom(currentRoom);
}

function updateRoomUI(roomId) {
    currentRoomTitle.textContent = `# ${capitalize(roomId)}`;
    
    roomBtns.forEach(btn => {
        if (btn.dataset.room === roomId) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    closeMobileSidebar();
}

// Helper Utilities
function scrollToBottom() {
    messageArea.scrollTop = messageArea.scrollHeight;
}

function getCurrentTime() {
    const now = new Date();
    return now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

// Mobile Sidebar Controls
function openMobileSidebar() {
    sidebar.classList.add('open');
    sidebarOverlay.classList.add('active');
}

function closeMobileSidebar() {
    sidebar.classList.remove('open');
    sidebarOverlay.classList.remove('active');
}

// Theme Toggle Handler
function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);

    const sunIcon = themeToggleBtn.querySelector('.sun-icon');
    const moonIcon = themeToggleBtn.querySelector('.moon-icon');

    if (newTheme === 'light') {
        sunIcon.classList.add('hidden');
        moonIcon.classList.remove('hidden');
    } else {
        sunIcon.classList.remove('hidden');
        moonIcon.classList.add('hidden');
    }
}

// Event Listeners Registration
usernameForm.addEventListener('submit', connect, true);
messageForm.addEventListener('submit', sendMessage, true);

messageInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        sendMessage(e);
    } else {
        emitTypingSignal();
    }
});

roomBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        switchRoom(btn.dataset.room);
    });
});

themeToggleBtn.addEventListener('click', toggleTheme);

emojiToggleBtn.addEventListener('click', () => {
    emojiDrawer.classList.toggle('hidden');
});

document.querySelectorAll('.emoji-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        messageInput.value += btn.textContent;
        messageInput.focus();
        emojiDrawer.classList.add('hidden');
    });
});

toggleSidebarBtn?.addEventListener('click', openMobileSidebar);
closeSidebarBtn?.addEventListener('click', closeMobileSidebar);
sidebarOverlay?.addEventListener('click', closeMobileSidebar);
