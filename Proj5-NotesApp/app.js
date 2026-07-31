/**
 * MEMOCHŌ — 90s Japanese Notes App
 * app.js — Full application logic
 */

'use strict';

/* ──────────────────────────────────────────────────
   STATE
────────────────────────────────────────────────── */
const STATE = {
  notes: [],           // All notes
  currentNote: null,   // Note being edited
  filter: 'all',       // 'all' | 'pinned' | 'archived' | tag
  search: '',
  sort: 'modified',    // 'modified' | 'created' | 'title'
  viewMode: 'grid',    // 'grid' | 'list'
  crt: true,
  previewMode: false,
  activeTagFilter: null,
  autoSaveTimer: null,
  isDragging: false,
  dragOffsetX: 0,
  dragOffsetY: 0,
};

const NOTE_COLORS = ['sakura', 'mint', 'lavender', 'yolk', 'neon', 'paper'];

const JP_STAMPS = ['✿', '★', '♪', '❋', '◆', '✦', '❀', '☆', '♦', '✸', '●', '▲'];

/* ──────────────────────────────────────────────────
   LOCAL STORAGE
────────────────────────────────────────────────── */
const STORAGE_KEY = 'memochō_notes_v1';

function loadNotes() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) STATE.notes = JSON.parse(raw);
  } catch (e) {
    console.warn('Failed to load notes from storage', e);
    STATE.notes = [];
  }
}

function saveNotes() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(STATE.notes));
  } catch (e) {
    showToast('⚠ Storage full! Delete some notes.', 'error');
  }
}

/* ──────────────────────────────────────────────────
   NOTE CRUD
────────────────────────────────────────────────── */
function createNote(overrides = {}) {
  const now = new Date().toISOString();
  return {
    id: `note_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    title: '',
    content: '',
    color: 'sakura',
    tags: [],
    pinned: false,
    archived: false,
    createdAt: now,
    modifiedAt: now,
    ...overrides,
  };
}

function saveCurrentNote(silent = false) {
  if (!STATE.currentNote) return;

  const title   = els.noteTitle.value.trim();
  const content = els.noteContent.value;

  if (!title && !content.trim()) {
    if (!silent) showToast('📭 Nothing to save — add a title or content first.', 'info');
    return;
  }

  STATE.currentNote.title = title || 'Untitled メモ';
  STATE.currentNote.content = content;
  STATE.currentNote.modifiedAt = new Date().toISOString();

  // Upsert
  const idx = STATE.notes.findIndex(n => n.id === STATE.currentNote.id);
  if (idx >= 0) {
    STATE.notes[idx] = { ...STATE.currentNote };
  } else {
    STATE.notes.unshift({ ...STATE.currentNote });
  }

  saveNotes();
  renderAll();
  updateSaveStatus('✓ Saved');
  if (!silent) showToast('💾 Note saved!', 'success');
}

function deleteNote(id) {
  STATE.notes = STATE.notes.filter(n => n.id !== id);
  saveNotes();
  renderAll();
}

function togglePin(id) {
  const note = STATE.notes.find(n => n.id === id);
  if (!note) return;
  note.pinned = !note.pinned;
  note.modifiedAt = new Date().toISOString();
  if (STATE.currentNote && STATE.currentNote.id === id) {
    STATE.currentNote.pinned = note.pinned;
  }
  saveNotes();
  renderAll();
  showToast(note.pinned ? '📌 Pinned!' : '📌 Unpinned', 'info');
}

function toggleArchive(id) {
  const note = STATE.notes.find(n => n.id === id);
  if (!note) return;
  note.archived = !note.archived;
  note.modifiedAt = new Date().toISOString();
  if (STATE.currentNote && STATE.currentNote.id === id) {
    STATE.currentNote.archived = note.archived;
  }
  saveNotes();
  renderAll();
  closeModal();
  showToast(note.archived ? '🗃 Archived!' : '🗃 Unarchived', 'info');
}

/* ──────────────────────────────────────────────────
   FILTERING & SORTING
────────────────────────────────────────────────── */
function getFilteredNotes() {
  let notes = [...STATE.notes];

  // Filter
  if (STATE.filter === 'pinned') {
    notes = notes.filter(n => n.pinned && !n.archived);
  } else if (STATE.filter === 'archived') {
    notes = notes.filter(n => n.archived);
  } else {
    // 'all' + tag filter
    if (STATE.activeTagFilter) {
      notes = notes.filter(n => n.tags.includes(STATE.activeTagFilter));
    } else {
      notes = notes.filter(n => !n.archived);
    }
  }

  // Search
  if (STATE.search) {
    const q = STATE.search.toLowerCase();
    notes = notes.filter(n =>
      n.title.toLowerCase().includes(q) ||
      n.content.toLowerCase().includes(q) ||
      n.tags.some(t => t.toLowerCase().includes(q))
    );
  }

  // Sort — pinned first, then by sort key
  notes.sort((a, b) => {
    if (a.pinned !== b.pinned) return a.pinned ? -1 : 1;
    switch (STATE.sort) {
      case 'created':  return new Date(b.createdAt)  - new Date(a.createdAt);
      case 'title':    return a.title.localeCompare(b.title);
      default:         return new Date(b.modifiedAt) - new Date(a.modifiedAt);
    }
  });

  return notes;
}

/* ──────────────────────────────────────────────────
   DOM ELEMENTS CACHE
────────────────────────────────────────────────── */
const els = {};
function cacheEls() {
  const ids = [
    'btn-new-note', 'btn-toggle-theme', 'btn-export', 'theme-icon',
    'search-input', 'btn-clear-search',
    'filter-chips', 'tag-cloud', 'sort-options',
    'stat-total', 'stat-pinned', 'stat-words',
    'notes-grid', 'results-count',
    'btn-grid-view', 'btn-list-view',
    'empty-state', 'btn-empty-new',
    'modal-overlay', 'modal',
    'modal-window-title', 'modal-color-picker',
    'btn-close-modal', 'btn-pin-modal', 'btn-maximize-modal',
    'note-title', 'note-content',
    'tag-input-area', 'tags-list', 'tag-input',
    'editor-toolbar', 'btn-preview-toggle',
    'note-preview',
    'char-count', 'word-count', 'save-status',
    'btn-delete-note', 'btn-archive-note', 'btn-save-note',
    'toast-container',
    'confirm-overlay', 'confirm-title', 'confirm-msg',
    'confirm-cancel', 'confirm-ok',
    'shortcuts-fab', 'shortcuts-panel',
    'ticker-tape',
  ];
  ids.forEach(id => {
    const key = id.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    els[key] = document.getElementById(id);
  });
  // Special selects
  els.filterChipsList  = document.querySelectorAll('.chip');
  els.sortBtns         = document.querySelectorAll('.sort-btn');
}

/* ──────────────────────────────────────────────────
   RENDER — NOTES GRID
────────────────────────────────────────────────── */
function renderAll() {
  renderNotes();
  renderStats();
  renderTagCloud();
  updateFilterChipCounts();
}

function renderNotes() {
  const notes = getFilteredNotes();
  const grid  = els.notesGrid;

  // Remove old cards (keep empty-state)
  Array.from(grid.children).forEach(child => {
    if (!child.id || child.id !== 'empty-state') grid.removeChild(child);
  });

  if (notes.length === 0) {
    els.emptyState.style.display = 'flex';
    els.resultsCount.textContent = '0 notes';
    return;
  }

  els.emptyState.style.display = 'none';
  els.resultsCount.textContent = `${notes.length} note${notes.length !== 1 ? 's' : ''}`;

  notes.forEach(note => {
    const card = buildNoteCard(note);
    grid.insertBefore(card, els.emptyState);
  });
}

function buildNoteCard(note) {
  const card = document.createElement('div');
  card.className = `note-card ${note.archived ? 'is-archived' : ''}`;
  card.dataset.color = note.color;
  card.dataset.id    = note.id;
  card.setAttribute('role', 'button');
  card.setAttribute('tabindex', '0');
  card.setAttribute('aria-label', `Open note: ${note.title || 'Untitled'}`);

  // Pin ribbon
  if (note.pinned) {
    const pin = document.createElement('div');
    pin.className = 'pin-ribbon';
    pin.textContent = '📌';
    pin.setAttribute('aria-hidden', 'true');
    card.appendChild(pin);
  }

  // Header
  const header = document.createElement('div');
  header.className = 'card-header';
  header.innerHTML = `
    <div class="card-icons">
      <span class="card-icon" aria-hidden="true">${getColorIcon(note.color)}</span>
    </div>
    <span class="card-date">${formatDate(note.modifiedAt)}</span>
  `;
  card.appendChild(header);

  // Body
  const body = document.createElement('div');
  body.className = 'card-body';
  const excerpt = note.content.replace(/[#*_~`>\[\]!]/g, '').trim();
  body.innerHTML = `
    <div class="card-title">${escapeHtml(note.title || 'Untitled メモ')}</div>
    <div class="card-excerpt">${escapeHtml(excerpt.slice(0, 200)) || '…'}</div>
  `;
  card.appendChild(body);

  // Footer with tags
  if (note.tags.length > 0) {
    const footer = document.createElement('div');
    footer.className = 'card-footer';
    note.tags.slice(0, 4).forEach(tag => {
      const t = document.createElement('span');
      t.className = 'card-tag';
      t.textContent = tag;
      footer.appendChild(t);
    });
    if (note.tags.length > 4) {
      const more = document.createElement('span');
      more.className = 'card-tag';
      more.textContent = `+${note.tags.length - 4}`;
      footer.appendChild(more);
    }
    card.appendChild(footer);
  }

  // Events
  card.addEventListener('click', () => openNote(note.id));
  card.addEventListener('keydown', e => {
    if (e.key === 'Enter' || e.key === ' ') openNote(note.id);
  });

  return card;
}

function getColorIcon(color) {
  const icons = { sakura: '🌸', mint: '🍀', lavender: '💜', yolk: '⭐', neon: '💎', paper: '📄' };
  return icons[color] || '📝';
}

function formatDate(iso) {
  const d = new Date(iso);
  const now = new Date();
  const diff = now - d;
  if (diff < 60_000)  return 'Just now';
  if (diff < 3600_000) return `${Math.floor(diff / 60_000)}m ago`;
  if (diff < 86400_000) return `${Math.floor(diff / 3600_000)}h ago`;
  return d.toLocaleDateString('ja-JP', { month: '2-digit', day: '2-digit', year: '2-digit' });
}

function escapeHtml(str) {
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ──────────────────────────────────────────────────
   RENDER — STATS
────────────────────────────────────────────────── */
function renderStats() {
  const visible = STATE.notes.filter(n => !n.archived);
  els.statTotal.textContent  = visible.length;
  els.statPinned.textContent = STATE.notes.filter(n => n.pinned).length;
  const totalWords = STATE.notes.reduce((acc, n) =>
    acc + (n.content.trim() ? n.content.trim().split(/\s+/).length : 0), 0);
  els.statWords.textContent  = totalWords > 999 ? `${(totalWords/1000).toFixed(1)}k` : totalWords;
}

/* ──────────────────────────────────────────────────
   RENDER — TAG CLOUD
────────────────────────────────────────────────── */
function renderTagCloud() {
  const allTags = {};
  STATE.notes.forEach(n => n.tags.forEach(t => { allTags[t] = (allTags[t] || 0) + 1; }));
  const tags = Object.keys(allTags);
  els.tagCloud.innerHTML = '';

  if (tags.length === 0) {
    els.tagCloud.innerHTML = '<span class="no-tags-msg">No tags yet!</span>';
    return;
  }

  tags.sort((a, b) => allTags[b] - allTags[a]).forEach(tag => {
    const pill = document.createElement('button');
    pill.className = `tag-pill ${STATE.activeTagFilter === tag ? 'active' : ''}`;
    pill.textContent = `${tag} (${allTags[tag]})`;
    pill.addEventListener('click', () => {
      STATE.activeTagFilter = STATE.activeTagFilter === tag ? null : tag;
      STATE.filter = 'all';
      updateFilterChips();
      renderAll();
    });
    els.tagCloud.appendChild(pill);
  });
}

/* ──────────────────────────────────────────────────
   FILTER CHIPS
────────────────────────────────────────────────── */
function updateFilterChipCounts() {
  document.querySelectorAll('.chip[data-filter]').forEach(chip => {
    const f = chip.dataset.filter;
    if (f === 'all') {
      const cnt = STATE.notes.filter(n => !n.archived).length;
      chip.textContent = `ALL (${cnt})`;
    }
  });
}

function updateFilterChips() {
  document.querySelectorAll('.chip').forEach(c => {
    c.classList.toggle('chip-active', c.dataset.filter === STATE.filter);
  });
}

/* ──────────────────────────────────────────────────
   MODAL — OPEN / CLOSE
────────────────────────────────────────────────── */
function openNote(id) {
  const note = STATE.notes.find(n => n.id === id);
  if (!note) return;

  STATE.currentNote = { ...note };
  populateModal(STATE.currentNote);
  showModal();
}

function openNewNote() {
  STATE.currentNote = createNote({ color: NOTE_COLORS[Math.floor(Math.random() * NOTE_COLORS.length)] });
  populateModal(STATE.currentNote);
  showModal();
  els.noteTitle.focus();
}

function populateModal(note) {
  els.noteTitle.value   = note.title === 'Untitled メモ' ? '' : note.title;
  els.noteContent.value = note.content;

  // Color picker
  document.querySelectorAll('.note-color-dot').forEach(d => {
    d.classList.toggle('active', d.dataset.color === note.color);
  });

  // Window title
  els.modalWindowTitle.textContent = note.title ? `✎ ${note.title} — メモ帳` : '✎ New Note — メモ帳';

  // Pin dot
  els.btnPinModal.title = note.pinned ? 'Unpin note' : 'Pin note';
  els.btnPinModal.style.background = note.pinned ? '#febc2e' : '';

  // Tags
  renderModalTags(note.tags);

  // Preview off
  STATE.previewMode = false;
  els.noteContent.classList.remove('hidden');
  els.notePreview.classList.add('hidden');
  els.btnPreviewToggle.classList.remove('active');
  els.btnPreviewToggle.textContent = '👁 Preview';

  updateWordCount();
  updateSaveStatus('✓ Saved');

  // Start auto-save
  startAutoSave();
}

function showModal() {
  els.modalOverlay.classList.remove('hidden');
  document.body.style.overflow = 'hidden';
}

function closeModal() {
  // Auto-save on close
  if (STATE.currentNote) saveCurrentNote(true);
  els.modalOverlay.classList.add('hidden');
  document.body.style.overflow = '';
  STATE.currentNote = null;
  clearAutoSave();
}

/* ──────────────────────────────────────────────────
   MODAL TAGS
────────────────────────────────────────────────── */
function renderModalTags(tags) {
  els.tagsList.innerHTML = '';
  tags.forEach(tag => addTagBadge(tag));
}

function addTagBadge(tag) {
  const badge = document.createElement('span');
  badge.className = 'tag-badge';
  badge.innerHTML = `${escapeHtml(tag)} <span class="tag-badge-remove" role="button" aria-label="Remove tag ${escapeHtml(tag)}" tabindex="0">✕</span>`;
  badge.querySelector('.tag-badge-remove').addEventListener('click', () => {
    removeTag(tag);
  });
  badge.querySelector('.tag-badge-remove').addEventListener('keydown', e => {
    if (e.key === 'Enter') removeTag(tag);
  });
  els.tagsList.appendChild(badge);
}

function addTag(rawTag) {
  const tag = rawTag.trim().toLowerCase().replace(/\s+/g, '-').slice(0, 25);
  if (!tag || !STATE.currentNote) return;
  if (STATE.currentNote.tags.includes(tag)) return;
  if (STATE.currentNote.tags.length >= 8) {
    showToast('⚠ Max 8 tags per note!', 'info');
    return;
  }
  STATE.currentNote.tags.push(tag);
  addTagBadge(tag);
}

function removeTag(tag) {
  if (!STATE.currentNote) return;
  STATE.currentNote.tags = STATE.currentNote.tags.filter(t => t !== tag);
  renderModalTags(STATE.currentNote.tags);
}

/* ──────────────────────────────────────────────────
   AUTO-SAVE
────────────────────────────────────────────────── */
function startAutoSave() {
  clearAutoSave();
  STATE.autoSaveTimer = setInterval(() => {
    if (STATE.currentNote) {
      saveCurrentNote(true);
    }
  }, 15000); // every 15s
}

function clearAutoSave() {
  if (STATE.autoSaveTimer) {
    clearInterval(STATE.autoSaveTimer);
    STATE.autoSaveTimer = null;
  }
}

/* ──────────────────────────────────────────────────
   WORD / CHAR COUNT
────────────────────────────────────────────────── */
function updateWordCount() {
  const text = els.noteContent.value;
  const chars = text.length;
  const words = text.trim() ? text.trim().split(/\s+/).length : 0;
  els.charCount.textContent = `${chars} char${chars !== 1 ? 's' : ''}`;
  els.wordCount.textContent = `${words} word${words !== 1 ? 's' : ''}`;
}

function updateSaveStatus(msg) {
  els.saveStatus.textContent = msg;
}

/* ──────────────────────────────────────────────────
   MARKDOWN PREVIEW (simple parser)
────────────────────────────────────────────────── */
function parseMarkdown(md) {
  let html = escapeHtml(md);

  // Code blocks
  html = html.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

  // Headers
  html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
  html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
  html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');

  // Blockquote
  html = html.replace(/^&gt; (.+)$/gm, '<blockquote>$1</blockquote>');

  // HR
  html = html.replace(/^(---|\*\*\*|─+)$/gm, '<hr>');

  // Bold, italic, strike
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
  html = html.replace(/~~(.+?)~~/g, '<del>$1</del>');

  // Checkboxes — must come before list parsing
  html = html.replace(/^- \[x\] (.+)$/gim, '<li><input type="checkbox" checked disabled> $1</li>');
  html = html.replace(/^- \[ \] (.+)$/gim, '<li><input type="checkbox" disabled> $1</li>');

  // Unordered lists
  html = html.replace(/^[•\-\*] (.+)$/gm, '<li>$1</li>');
  html = html.replace(/((<li>.*<\/li>\n?)+)/g, '<ul>$1</ul>');

  // Ordered lists
  html = html.replace(/^\d+\. (.+)$/gm, '<li>$1</li>');

  // Line breaks
  html = html.replace(/\n\n/g, '</p><p>');
  html = html.replace(/\n/g, '<br>');
  html = `<p>${html}</p>`;

  return html;
}

function refreshPreview() {
  els.notePreview.innerHTML = parseMarkdown(els.noteContent.value);
}

/* ──────────────────────────────────────────────────
   TOOLBAR ACTIONS (Markdown insertions)
────────────────────────────────────────────────── */
function applyToolbarAction(action) {
  const ta   = els.noteContent;
  const start = ta.selectionStart;
  const end   = ta.selectionEnd;
  const sel   = ta.value.slice(start, end);
  let   prefix = '', suffix = '', full = null;

  switch (action) {
    case 'bold':     prefix = '**'; suffix = '**'; break;
    case 'italic':   prefix = '*';  suffix = '*';  break;
    case 'strike':   prefix = '~~'; suffix = '~~'; break;
    case 'h1':       prefix = '\n# '; suffix = ''; break;
    case 'h2':       prefix = '\n## '; suffix = ''; break;
    case 'ul':       prefix = '\n- '; suffix = ''; break;
    case 'ol':       prefix = '\n1. '; suffix = ''; break;
    case 'checkbox': prefix = '\n- [ ] '; suffix = ''; break;
    case 'hr':       full = '\n\n---\n\n'; break;
    case 'stamp': {
      const s = JP_STAMPS[Math.floor(Math.random() * JP_STAMPS.length)];
      full = ` ${s} `;
      break;
    }
    default: return;
  }

  const insert = full !== null ? full : `${prefix}${sel}${suffix}`;
  const before = ta.value.slice(0, start);
  const after  = ta.value.slice(end);
  ta.value = before + insert + after;
  ta.selectionStart = ta.selectionEnd = start + insert.length;
  ta.focus();
  updateWordCount();
  markUnsaved();
}

function markUnsaved() {
  updateSaveStatus('⏳ Unsaved…');
}

/* ──────────────────────────────────────────────────
   TOAST NOTIFICATIONS
────────────────────────────────────────────────── */
function showToast(msg, type = 'success', duration = 2800) {
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.textContent = msg;
  toast.setAttribute('role', 'status');
  els.toastContainer.appendChild(toast);
  setTimeout(() => {
    toast.classList.add('toast-out');
    toast.addEventListener('animationend', () => toast.remove(), { once: true });
  }, duration);
}

/* ──────────────────────────────────────────────────
   CONFIRM DIALOG
────────────────────────────────────────────────── */
let _confirmResolve = null;

function showConfirm(title, msg) {
  return new Promise(resolve => {
    _confirmResolve = resolve;
    els.confirmTitle.textContent = title;
    els.confirmMsg.textContent   = msg;
    els.confirmOverlay.classList.remove('hidden');
  });
}

/* ──────────────────────────────────────────────────
   EXPORT (JSON & Plain Text)
────────────────────────────────────────────────── */
function exportNotes() {
  const visible = STATE.notes.filter(n => !n.archived);
  if (visible.length === 0) { showToast('📭 No notes to export!', 'info'); return; }

  // Build plain text export
  const txt = visible.map(n =>
    `=== ${n.title || 'Untitled'} ===\n[${n.color}] ${n.tags.join(', ')}\n${formatDate(n.modifiedAt)}\n\n${n.content}\n`
  ).join('\n' + '─'.repeat(40) + '\n\n');

  const blob = new Blob([txt], { type: 'text/plain; charset=utf-8' });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement('a');
  a.href     = url;
  a.download = `memochō_export_${new Date().toISOString().slice(0,10)}.txt`;
  a.click();
  URL.revokeObjectURL(url);
  showToast('💾 Notes exported!', 'success');
}

/* ──────────────────────────────────────────────────
   DRAG — Modal window (retro OS window drag)
────────────────────────────────────────────────── */
function initDrag() {
  const header = document.getElementById('modal-header');
  const modal  = els.modal;

  header.addEventListener('mousedown', e => {
    if (e.target.classList.contains('dot') || e.target.classList.contains('note-color-dot')) return;
    STATE.isDragging = true;
    const rect = modal.getBoundingClientRect();
    STATE.dragOffsetX = e.clientX - rect.left;
    STATE.dragOffsetY = e.clientY - rect.top;
    modal.style.position = 'fixed';
    modal.style.margin   = '0';
    modal.style.left     = `${rect.left}px`;
    modal.style.top      = `${rect.top}px`;
    e.preventDefault();
  });

  document.addEventListener('mousemove', e => {
    if (!STATE.isDragging) return;
    let x = e.clientX - STATE.dragOffsetX;
    let y = e.clientY - STATE.dragOffsetY;
    x = Math.max(0, Math.min(window.innerWidth  - modal.offsetWidth,  x));
    y = Math.max(0, Math.min(window.innerHeight - modal.offsetHeight, y));
    modal.style.left = `${x}px`;
    modal.style.top  = `${y}px`;
  });

  document.addEventListener('mouseup', () => { STATE.isDragging = false; });
}

function resetModalPosition() {
  els.modal.style.position = '';
  els.modal.style.left     = '';
  els.modal.style.top      = '';
}

/* ──────────────────────────────────────────────────
   TICKER UPDATE (dynamic)
────────────────────────────────────────────────── */
function updateTicker() {
  const cnt   = STATE.notes.filter(n => !n.archived).length;
  const words = STATE.notes.reduce((acc, n) =>
    acc + (n.content.trim() ? n.content.trim().split(/\s+/).length : 0), 0);
  const now   = new Date().toLocaleString('ja-JP');
  const msgs  = [
    '✿ ようこそ！WELCOME TO MEMOCHŌ ✿',
    `★ ${cnt} NOTES STORED IN YOUR MEMORY ★`,
    `♪ ${words} WORDS ACROSS ALL NOTES ♪`,
    `❋ ${now} ❋`,
    '◆ PRESS CTRL+N FOR A NEW NOTE ◆',
    '✿ ようこそ！WELCOME TO MEMOCHŌ ✿',
    `★ ${cnt} NOTES STORED IN YOUR MEMORY ★`,
  ];
  const tape = els.tickerTape;
  tape.innerHTML = msgs.map(m => `<span>${m}</span>`).join('');
}

/* ──────────────────────────────────────────────────
   KEYBOARD SHORTCUTS
────────────────────────────────────────────────── */
function handleGlobalKeys(e) {
  const inModal = !els.modalOverlay.classList.contains('hidden');

  if (e.ctrlKey || e.metaKey) {
    switch (e.key.toLowerCase()) {
      case 'n':
        e.preventDefault();
        if (!inModal) openNewNote();
        break;
      case 's':
        e.preventDefault();
        if (inModal) saveCurrentNote();
        break;
      case 'b':
        if (inModal) { e.preventDefault(); applyToolbarAction('bold'); }
        break;
      case 'i':
        if (inModal) { e.preventDefault(); applyToolbarAction('italic'); }
        break;
      case 'p':
        if (inModal) { e.preventDefault(); togglePreview(); }
        break;
    }
  }

  if (e.key === 'Escape') {
    if (!document.getElementById('confirm-overlay').classList.contains('hidden')) {
      closeConfirm(false);
    } else if (inModal) {
      closeModal();
    }
    if (!els.shortcutsPanel.classList.contains('hidden')) {
      els.shortcutsPanel.classList.add('hidden');
    }
  }
}

/* ──────────────────────────────────────────────────
   TOGGLE PREVIEW
────────────────────────────────────────────────── */
function togglePreview() {
  STATE.previewMode = !STATE.previewMode;
  if (STATE.previewMode) {
    refreshPreview();
    els.noteContent.classList.add('hidden');
    els.notePreview.classList.remove('hidden');
    els.btnPreviewToggle.classList.add('active');
    els.btnPreviewToggle.textContent = '✎ Edit';
  } else {
    els.noteContent.classList.remove('hidden');
    els.notePreview.classList.add('hidden');
    els.btnPreviewToggle.classList.remove('active');
    els.btnPreviewToggle.textContent = '👁 Preview';
  }
}

function closeConfirm(result) {
  els.confirmOverlay.classList.add('hidden');
  if (_confirmResolve) { _confirmResolve(result); _confirmResolve = null; }
}

/* ──────────────────────────────────────────────────
   EVENT BINDINGS
────────────────────────────────────────────────── */
function bindEvents() {
  // New note
  els.btnNewNote.addEventListener('click', openNewNote);
  els.btnEmptyNew.addEventListener('click', openNewNote);

  // Theme toggle (CRT)
  els.btnToggleTheme.addEventListener('click', () => {
    STATE.crt = !STATE.crt;
    document.body.classList.toggle('no-crt', !STATE.crt);
    els.themeIcon.textContent = STATE.crt ? '📺' : '🖥';
    showToast(STATE.crt ? '📺 CRT ON' : '🖥 CRT OFF', 'info');
  });

  // Export
  els.btnExport.addEventListener('click', exportNotes);

  // Search
  els.searchInput.addEventListener('input', e => {
    STATE.search = e.target.value;
    renderNotes();
  });
  els.btnClearSearch.addEventListener('click', () => {
    els.searchInput.value = '';
    STATE.search = '';
    renderNotes();
  });

  // Filter chips (delegated on container)
  document.getElementById('filter-chips').addEventListener('click', e => {
    const chip = e.target.closest('[data-filter]');
    if (!chip) return;
    STATE.filter = chip.dataset.filter;
    STATE.activeTagFilter = null;
    updateFilterChips();
    renderAll();
  });

  // Sort
  document.querySelectorAll('.sort-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      STATE.sort = btn.dataset.sort;
      document.querySelectorAll('.sort-btn').forEach(b => b.classList.remove('sort-active'));
      btn.classList.add('sort-active');
      renderNotes();
    });
  });

  // View toggle
  els.btnGridView.addEventListener('click', () => {
    STATE.viewMode = 'grid';
    els.notesGrid.classList.remove('list-view');
    els.btnGridView.classList.add('view-active');
    els.btnListView.classList.remove('view-active');
  });
  els.btnListView.addEventListener('click', () => {
    STATE.viewMode = 'list';
    els.notesGrid.classList.add('list-view');
    els.btnListView.classList.add('view-active');
    els.btnGridView.classList.remove('view-active');
  });

  // Modal close
  els.btnCloseModal.addEventListener('click', closeModal);
  els.btnCloseModal.addEventListener('keydown', e => { if (e.key === 'Enter') closeModal(); });
  els.modalOverlay.addEventListener('click', e => {
    if (e.target === els.modalOverlay) closeModal();
  });

  // Pin
  els.btnPinModal.addEventListener('click', () => {
    if (!STATE.currentNote) return;
    togglePin(STATE.currentNote.id);
    // Update dot color
    const isPinned = STATE.notes.find(n => n.id === STATE.currentNote.id)?.pinned;
    els.btnPinModal.style.background = isPinned ? '#febc2e' : '';
  });
  els.btnPinModal.addEventListener('keydown', e => { if (e.key === 'Enter') els.btnPinModal.click(); });

  // Maximize
  els.btnMaximizeModal.addEventListener('click', () => {
    els.modal.classList.toggle('maximized');
    resetModalPosition();
  });
  els.btnMaximizeModal.addEventListener('keydown', e => { if (e.key === 'Enter') els.btnMaximizeModal.click(); });

  // Color picker
  document.getElementById('modal-color-picker').addEventListener('click', e => {
    const dot = e.target.closest('.note-color-dot');
    if (!dot || !STATE.currentNote) return;
    STATE.currentNote.color = dot.dataset.color;
    document.querySelectorAll('.note-color-dot').forEach(d => d.classList.toggle('active', d === dot));
    markUnsaved();
  });

  // Note title
  els.noteTitle.addEventListener('input', () => {
    markUnsaved();
    els.modalWindowTitle.textContent = `✎ ${els.noteTitle.value || 'New Note'} — メモ帳`;
  });

  // Note content
  els.noteContent.addEventListener('input', () => {
    updateWordCount();
    markUnsaved();
  });

  // Tag input
  els.tagInput.addEventListener('keydown', e => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      addTag(els.tagInput.value);
      els.tagInput.value = '';
    }
    if (e.key === 'Backspace' && !els.tagInput.value && STATE.currentNote?.tags.length > 0) {
      removeTag(STATE.currentNote.tags[STATE.currentNote.tags.length - 1]);
    }
  });

  // Editor toolbar
  document.getElementById('editor-toolbar').addEventListener('click', e => {
    const btn = e.target.closest('[data-action]');
    if (btn) applyToolbarAction(btn.dataset.action);
    if (e.target === els.btnPreviewToggle || e.target.closest('#btn-preview-toggle') === els.btnPreviewToggle) {
      togglePreview();
    }
  });

  // Save / Delete / Archive
  els.btnSaveNote.addEventListener('click', () => saveCurrentNote());

  els.btnDeleteNote.addEventListener('click', async () => {
    if (!STATE.currentNote) return;
    const existing = STATE.notes.find(n => n.id === STATE.currentNote.id);
    if (!existing) { closeModal(); return; } // unsaved, just close
    const ok = await showConfirm('🗑 DELETE NOTE?', `Are you sure you want to permanently delete "${existing.title || 'this note'}"?`);
    if (ok) {
      deleteNote(STATE.currentNote.id);
      closeModal();
      showToast('🗑 Note deleted!', 'error');
    }
  });

  els.btnArchiveNote.addEventListener('click', () => {
    if (!STATE.currentNote) return;
    const existing = STATE.notes.find(n => n.id === STATE.currentNote.id);
    if (!existing) {
      showToast('Save the note first!', 'info');
      return;
    }
    toggleArchive(STATE.currentNote.id);
  });

  // Confirm dialog
  els.confirmOk.addEventListener('click', () => closeConfirm(true));
  els.confirmCancel.addEventListener('click', () => closeConfirm(false));

  // Shortcuts FAB
  els.shortcutsFab.addEventListener('click', () => {
    els.shortcutsPanel.classList.toggle('hidden');
  });

  // Global keys
  document.addEventListener('keydown', handleGlobalKeys);

  // Init modal drag
  initDrag();
}

/* ──────────────────────────────────────────────────
   SEED DEMO NOTES (first launch)
────────────────────────────────────────────────── */
function seedDemoNotes() {
  if (STATE.notes.length > 0) return;

  const demos = [
    {
      title: 'ようこそ！Welcome to Memochō',
      content: `# ✿ Welcome to Memochō! ✿

This is your **90s Japanese-style** notes app!

## Features
- ✦ **Write** notes in Markdown
- ✦ **Color-code** with 6 pastel themes
- ✦ **Tag** and organize your thoughts
- ✦ **Pin** important notes
- ✦ **Search** across all your notes
- ✦ **Preview** rendered Markdown

## Keyboard Shortcuts
- \`Ctrl+N\` — New Note
- \`Ctrl+S\` — Save
- \`Ctrl+B\` — **Bold**
- \`Ctrl+P\` — Preview mode

> Write beautifully. Remember everything. ♪

*Enjoy your Memochō experience!*`,
      color: 'sakura',
      tags: ['welcome', 'guide'],
      pinned: true,
    },
    {
      title: '買い物リスト — Shopping List',
      content: `# 🛒 今週の買い物

- [ ] Matcha green tea powder
- [ ] Mochi (strawberry flavor)
- [x] Soy sauce
- [ ] Instant ramen × 5
- [ ] Pocky sticks
- [x] Seaweed snacks
- [ ] Yuzu honey

---
**Budget:** ¥3,500`,
      color: 'mint',
      tags: ['shopping', 'list'],
    },
    {
      title: '夢日記 — Dream Journal',
      content: `## 🌙 Last Night's Dream

I was wandering through **Shibuya at night**, 1999.

Neon signs everywhere — pink, cyan, magenta. The streets were empty but the arcades were *full of light*.

Someone was playing a melody on a ~~broken~~ koto instrument near the crossing...

> "The city remembers what you forget."

### Notes
- The dream had a **VHS aesthetic**
- Colors were oversaturated like an old anime OP
- Woke up at 3:33 AM ✦`,
      color: 'lavender',
      tags: ['journal', 'dreams'],
    },
    {
      title: '覚書 — Quick Reminders',
      content: `# ⭐ Today's Reminders

1. Call Tanaka-san before 5PM
2. Submit project report
3. Water the ferns
4. Download the new City Pop album

---
✸ *Don't forget the umbrella — rain forecast!* ✸`,
      color: 'yolk',
      tags: ['todo', 'reminders'],
    },
  ];

  demos.forEach((d, i) => {
    const base = new Date();
    base.setDate(base.getDate() - i);
    const note = createNote({
      ...d,
      createdAt: base.toISOString(),
      modifiedAt: base.toISOString(),
    });
    STATE.notes.push(note);
  });

  saveNotes();
}

/* ──────────────────────────────────────────────────
   INIT
────────────────────────────────────────────────── */
function init() {
  cacheEls();
  loadNotes();
  seedDemoNotes();
  bindEvents();
  renderAll();
  updateTicker();

  // Update ticker every 30s
  setInterval(updateTicker, 30_000);

  // Startup message
  setTimeout(() => {
    showToast('✿ ようこそ！ Welcome back to Memochō!', 'success', 3500);
  }, 600);
}

document.addEventListener('DOMContentLoaded', init);
