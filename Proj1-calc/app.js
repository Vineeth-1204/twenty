/* ==========================================================================
   SPIDER-MAN MULTIVERSE CALCULATOR - APPLICATION LOGIC
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // ========================================================================
  // STATE MANAGEMENT
  // ========================================================================
  const state = {
    currentInput: '0',
    expression: '',
    result: null,
    isEvaluated: false,
    soundEnabled: true,
    angleMode: 'DEG', // 'DEG' or 'RAD'
    sciMode: false,
    suit: 'classic',
    history: JSON.parse(localStorage.getItem('spidey_calc_history') || '[]')
  };

  // ========================================================================
  // DOM ELEMENTS
  // ========================================================================
  const mainResultEl = document.getElementById('main-result');
  const expressionDisplayEl = document.getElementById('expression-display');
  const spideyEyesEl = document.getElementById('spidey-eyes');
  const spideyQuoteEl = document.getElementById('spidey-quote');
  const hudDisplayEl = document.getElementById('hud-display');
  const comicPopupLayer = document.getElementById('comic-popup-layer');
  const angleModeBadge = document.getElementById('angle-mode-badge');
  const degRadBtn = document.getElementById('deg-rad-btn');
  const soundToggleBtn = document.getElementById('sound-toggle');
  const modeToggleBtn = document.getElementById('mode-toggle');
  const historyToggleBtn = document.getElementById('history-toggle');
  const historyDrawerEl = document.getElementById('history-drawer');
  const drawerBackdropEl = document.getElementById('drawer-backdrop');
  const closeHistoryBtn = document.getElementById('close-history');
  const historyListEl = document.getElementById('history-list');
  const clearHistoryBtn = document.getElementById('clear-history-btn');
  const scientificPanelEl = document.getElementById('scientific-panel');
  const suitButtons = document.querySelectorAll('.suit-btn');
  const keys = document.querySelectorAll('.key');

  // ========================================================================
  // WEB AUDIO SYNTHESIZER (Web-Shooter Sound Engine)
  // ========================================================================
  let audioCtx = null;

  function initAudio() {
    if (!audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      audioCtx = new AudioContext();
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
  }

  // Realistic "Thwip!" Web-Shooter Sound Effect
  function playThwipSound() {
    if (!state.soundEnabled) return;
    initAudio();
    if (!audioCtx) return;

    const now = audioCtx.currentTime;

    // Oscillator 1: High frequency pitch sweep
    const osc = audioCtx.createOscillator();
    const gainOsc = audioCtx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(400, now);
    osc.frequency.exponentialRampToValueAtTime(1600, now + 0.04);
    osc.frequency.exponentialRampToValueAtTime(200, now + 0.12);

    gainOsc.gain.setValueAtTime(0.3, now);
    gainOsc.gain.exponentialRampToValueAtTime(0.01, now + 0.12);

    osc.connect(gainOsc);
    gainOsc.connect(audioCtx.destination);
    osc.start(now);
    osc.stop(now + 0.12);

    // Noise Burst for air/web whip effect
    const bufferSize = audioCtx.sampleRate * 0.1;
    const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
    const output = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      output[i] = Math.random() * 2 - 1;
    }

    const whiteNoise = audioCtx.createBufferSource();
    whiteNoise.buffer = buffer;

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(1200, now);
    filter.Q.setValueAtTime(3, now);

    const gainNoise = audioCtx.createGain();
    gainNoise.gain.setValueAtTime(0.4, now);
    gainNoise.gain.exponentialRampToValueAtTime(0.001, now + 0.1);

    whiteNoise.connect(filter);
    filter.connect(gainNoise);
    gainNoise.connect(audioCtx.destination);

    whiteNoise.start(now);
    whiteNoise.stop(now + 0.1);
  }

  function playClickSound() {
    if (!state.soundEnabled) return;
    initAudio();
    if (!audioCtx) return;

    const now = audioCtx.currentTime;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(600, now);
    osc.frequency.exponentialRampToValueAtTime(300, now + 0.03);

    gain.gain.setValueAtTime(0.15, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + 0.03);

    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.start(now);
    osc.stop(now + 0.03);
  }

  function playClearSound() {
    if (!state.soundEnabled) return;
    initAudio();
    if (!audioCtx) return;

    const now = audioCtx.currentTime;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(800, now);
    osc.frequency.exponentialRampToValueAtTime(150, now + 0.15);

    gain.gain.setValueAtTime(0.2, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + 0.15);

    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.start(now);
    osc.stop(now + 0.15);
  }

  function playErrorSound() {
    if (!state.soundEnabled) return;
    initAudio();
    if (!audioCtx) return;

    const now = audioCtx.currentTime;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(130, now);
    osc.frequency.setValueAtTime(90, now + 0.08);

    gain.gain.setValueAtTime(0.3, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + 0.25);

    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.start(now);
    osc.stop(now + 0.25);
  }

  // ========================================================================
  // SPIDEY QUOTES & COMIC POPUPS
  // ========================================================================
  const spideyQuotes = {
    normal: [
      "With great power comes great mathematical precision!",
      "Spider-Sense is tingling... that formula checks out!",
      "Math-Man to the rescue! Easy peasy.",
      "Slinging equations faster than Green Goblin can dodge!",
      "Multiverse certified calculation!",
      "Just your friendly neighborhood calculator doing its job."
    ],
    big: [
      "Woah! That's a bigger number than Stark Tower's electric bill!",
      "Calculated with quantum Spider-tech!",
      "Boom! Multilingual Math Master in action!"
    ],
    error: [
      "Universe collapsed! Can't divide by zero, Web-Head!",
      "Spider-Sense warning! Invalid mathematical trajectory!",
      "Ouch! Even Peter Parker couldn't solve that glitch!"
    ]
  };

  const actionWords = ["THWIP!", "BAM!", "SPIDEY MATH!", "WEB SLING!", "ZAP!", "BOOM!", "MATH SENSE!"];

  function updateSpideyQuote(category = 'normal') {
    const quotes = spideyQuotes[category] || spideyQuotes.normal;
    const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
    spideyQuoteEl.textContent = `"${randomQuote}"`;
  }

  function triggerComicPopup() {
    const word = actionWords[Math.floor(Math.random() * actionWords.length)];
    const popup = document.createElement('div');
    popup.className = 'comic-popup';
    popup.textContent = word;
    comicPopupLayer.appendChild(popup);

    setTimeout(() => {
      popup.remove();
    }, 750);
  }

  function triggerSpideyEyeAnimation(stateName = 'squint') {
    spideyEyesEl.classList.remove('squint', 'shock');
    void spideyEyesEl.offsetWidth; // Force reflow
    spideyEyesEl.classList.add(stateName);

    setTimeout(() => {
      spideyEyesEl.classList.remove(stateName);
    }, 600);
  }

  // ========================================================================
  // INTERACTIVE CANVASES (Spider Web Animation)
  // ========================================================================
  const canvas = document.getElementById('web-canvas');
  const ctx = canvas.getContext('2d');
  let width, height;
  const nodes = [];
  let mouse = { x: null, y: null };

  function resizeCanvas() {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
    createNodes();
  }

  function createNodes() {
    nodes.length = 0;
    const nodeCount = Math.floor((width * height) / 18000);
    for (let i = 0; i < nodeCount; i++) {
      nodes.push({
        x: Math.random() * width,
        y: Math.random() * height,
        vx: (Math.random() - 0.5) * 0.8,
        vy: (Math.random() - 0.5) * 0.8,
        radius: Math.random() * 2 + 1
      });
    }
  }

  function drawWebs() {
    ctx.clearRect(0, 0, width, height);

    // Draw connecting lines
    for (let i = 0; i < nodes.length; i++) {
      const nodeA = nodes[i];
      nodeA.x += nodeA.vx;
      nodeA.y += nodeA.vy;

      if (nodeA.x < 0 || nodeA.x > width) nodeA.vx *= -1;
      if (nodeA.y < 0 || nodeA.y > height) nodeA.vy *= -1;

      // Mouse attraction
      if (mouse.x !== null) {
        const dx = mouse.x - nodeA.x;
        const dy = mouse.y - nodeA.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 150) {
          ctx.beginPath();
          ctx.moveTo(nodeA.x, nodeA.y);
          ctx.lineTo(mouse.x, mouse.y);
          ctx.strokeStyle = `rgba(0, 242, 254, ${0.4 * (1 - dist / 150)})`;
          ctx.lineWidth = 1;
          ctx.stroke();
        }
      }

      for (let j = i + 1; j < nodes.length; j++) {
        const nodeB = nodes[j];
        const dx = nodeB.x - nodeA.x;
        const dy = nodeB.y - nodeA.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < 120) {
          ctx.beginPath();
          ctx.moveTo(nodeA.x, nodeA.y);
          ctx.lineTo(nodeB.x, nodeB.y);
          ctx.strokeStyle = `rgba(255, 255, 255, ${0.15 * (1 - dist / 120)})`;
          ctx.lineWidth = 0.8;
          ctx.stroke();
        }
      }

      ctx.beginPath();
      ctx.arc(nodeA.x, nodeA.y, nodeA.radius, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
      ctx.fill();
    }

    requestAnimationFrame(drawWebs);
  }

  window.addEventListener('resize', resizeCanvas);
  window.addEventListener('mousemove', (e) => {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
  });

  resizeCanvas();
  drawWebs();

  // Web Burst Effect on Button Click
  function createWebBurst(x, y) {
    for (let i = 0; i < 8; i++) {
      const angle = (Math.PI * 2 / 8) * i;
      nodes.push({
        x: x,
        y: y,
        vx: Math.cos(angle) * (Math.random() * 4 + 2),
        vy: Math.sin(angle) * (Math.random() * 4 + 2),
        radius: 2
      });
    }
    if (nodes.length > 80) {
      nodes.splice(0, 8);
    }
  }

  // ========================================================================
  // CALCULATOR LOGIC & MATH ENGINE
  // ========================================================================
  function renderDisplay() {
    expressionDisplayEl.textContent = state.expression || '0';

    if (state.result !== null) {
      mainResultEl.textContent = state.result;
      mainResultEl.classList.remove('error-text');
    } else {
      mainResultEl.textContent = state.currentInput;
      mainResultEl.classList.remove('error-text');
    }
  }

  function appendCharacter(char) {
    if (state.isEvaluated) {
      if (['+', '−', '×', '÷', '%', '^'].includes(char)) {
        state.expression = state.result.toString() + ' ' + char + ' ';
      } else {
        state.expression = char;
      }
      state.currentInput = char;
      state.isEvaluated = false;
      state.result = null;
    } else {
      if (state.expression === '0' && char !== '.') {
        state.expression = char;
      } else {
        state.expression += char;
      }
      state.currentInput = char;
    }
    renderDisplay();
    triggerSpideyEyeAnimation('squint');
  }

  function handleOperator(op) {
    if (state.isEvaluated) {
      state.expression = state.result.toString() + ' ' + op + ' ';
      state.isEvaluated = false;
      state.result = null;
    } else {
      if (!state.expression) state.expression = '0';
      state.expression += ' ' + op + ' ';
    }
    renderDisplay();
    triggerSpideyEyeAnimation('squint');
  }

  function clearAll() {
    state.currentInput = '0';
    state.expression = '';
    state.result = null;
    state.isEvaluated = false;
    playClearSound();
    renderDisplay();
    updateSpideyQuote('normal');
  }

  function clearEntry() {
    state.expression = state.expression.slice(0, -1);
    if (!state.expression) state.expression = '0';
    playClearSound();
    renderDisplay();
  }

  function backspace() {
    if (state.isEvaluated) {
      clearAll();
      return;
    }
    state.expression = state.expression.trimEnd();
    state.expression = state.expression.slice(0, -1);
    if (!state.expression) state.expression = '0';
    playClickSound();
    renderDisplay();
  }

  function handleNegate() {
    if (state.isEvaluated && state.result) {
      state.result = (parseFloat(state.result) * -1).toString();
      renderDisplay();
      return;
    }
    if (state.expression.startsWith('-')) {
      state.expression = state.expression.slice(1);
    } else {
      state.expression = '-' + state.expression;
    }
    renderDisplay();
  }

  function factorial(n) {
    if (n < 0) return NaN;
    if (n === 0 || n === 1) return 1;
    let res = 1;
    for (let i = 2; i <= n; i++) res *= i;
    return res;
  }

  function evaluateExpression() {
    if (!state.expression) return;

    let expr = state.expression
      .replace(/×/g, '*')
      .replace(/÷/g, '/')
      .replace(/−/g, '-')
      .replace(/π/g, 'Math.PI')
      .replace(/e/g, 'Math.E');

    // Handle DEG vs RAD for trigonometric functions
    const isDeg = state.angleMode === 'DEG';

    try {
      // Replace custom functions
      expr = expr.replace(/sin\(([^)]+)\)/g, (_, val) => `Math.sin(${isDeg ? `(${val}) * Math.PI / 180` : val})`);
      expr = expr.replace(/cos\(([^)]+)\)/g, (_, val) => `Math.cos(${isDeg ? `(${val}) * Math.PI / 180` : val})`);
      expr = expr.replace(/tan\(([^)]+)\)/g, (_, val) => `Math.tan(${isDeg ? `(${val}) * Math.PI / 180` : val})`);
      expr = expr.replace(/log\(([^)]+)\)/g, (_, val) => `Math.log10(${val})`);
      expr = expr.replace(/ln\(([^)]+)\)/g, (_, val) => `Math.log(${val})`);
      expr = expr.replace(/√\(([^)]+)\)/g, (_, val) => `Math.sqrt(${val})`);
      expr = expr.replace(/√([0-9.]+)/g, (_, val) => `Math.sqrt(${val})`);
      expr = expr.replace(/(\d+)\^(\d+)/g, (_, base, exp) => `Math.pow(${base}, ${exp})`);

      // Safe Function Evaluator
      const rawResult = Function(`"use strict"; return (${expr})`)();

      if (!isFinite(rawResult) || isNaN(rawResult)) {
        throw new Error("Mathematical Infinity or Error");
      }

      // Format clean precision
      let formattedResult = Number(Math.round(rawResult + 'e10') + 'e-10').toString();

      state.result = formattedResult;
      state.isEvaluated = true;

      // HUD Web Glow Animation
      hudDisplayEl.classList.add('web-active');
      setTimeout(() => hudDisplayEl.classList.remove('web-active'), 600);

      // Sound & Eye Effects
      playThwipSound();
      triggerComicPopup();

      if (Math.abs(parseFloat(formattedResult)) > 1000000) {
        updateSpideyQuote('big');
        triggerSpideyEyeAnimation('shock');
      } else {
        updateSpideyQuote('normal');
        triggerSpideyEyeAnimation('squint');
      }

      // Save to History
      saveHistory(state.expression, formattedResult);
      renderDisplay();

    } catch (err) {
      playErrorSound();
      mainResultEl.textContent = "SPIDEY ERROR";
      mainResultEl.classList.add('error-text');
      updateSpideyQuote('error');
      triggerSpideyEyeAnimation('shock');
    }
  }

  function handleSciFunction(fn) {
    if (fn === 'deg-rad') {
      state.angleMode = state.angleMode === 'DEG' ? 'RAD' : 'DEG';
      angleModeBadge.textContent = state.angleMode;
      degRadBtn.textContent = state.angleMode;
      playClickSound();
      return;
    }

    if (['sin', 'cos', 'tan', 'log', 'ln'].includes(fn)) {
      state.expression += `${fn}(`;
    } else if (fn === 'sqrt') {
      state.expression += `√(`;
    } else if (fn === 'square') {
      state.expression += `^2`;
    } else if (fn === 'pow') {
      state.expression += `^`;
    } else if (fn === 'pi') {
      state.expression += `π`;
    } else if (fn === 'e') {
      state.expression += `e`;
    } else if (fn === 'open-paren') {
      state.expression += `(`;
    } else if (fn === 'close-paren') {
      state.expression += `)`;
    } else if (fn === 'abs') {
      state.expression = `Math.abs(${state.expression})`;
    } else if (fn === 'factorial') {
      state.expression += `!`;
    }

    playClickSound();
    renderDisplay();
  }

  // ========================================================================
  // HISTORY LOG MANAGER
  // ========================================================================
  function saveHistory(expr, res) {
    const item = { expr, res, time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) };
    state.history.unshift(item);
    if (state.history.length > 30) state.history.pop();
    localStorage.setItem('spidey_calc_history', JSON.stringify(state.history));
    renderHistory();
  }

  function renderHistory() {
    if (state.history.length === 0) {
      historyListEl.innerHTML = `<div class="empty-history">No webs slung yet. Start calculating!</div>`;
      return;
    }

    historyListEl.innerHTML = state.history.map(item => `
      <div class="history-item" data-expr="${item.expr}" data-res="${item.res}">
        <div class="item-expr">${item.expr} =</div>
        <div class="item-res">${item.res}</div>
      </div>
    `).join('');

    // Attach click listeners to history items
    document.querySelectorAll('.history-item').forEach(el => {
      el.addEventListener('click', () => {
        state.expression = el.dataset.res;
        state.result = null;
        state.isEvaluated = false;
        renderDisplay();
        toggleHistoryDrawer(false);
        playClickSound();
      });
    });
  }

  function toggleHistoryDrawer(open) {
    const isOpen = open !== undefined ? open : !historyDrawerEl.classList.contains('open');
    if (isOpen) {
      renderHistory();
      historyDrawerEl.classList.add('open');
      drawerBackdropEl.classList.add('show');
    } else {
      historyDrawerEl.classList.remove('open');
      drawerBackdropEl.classList.remove('show');
    }
  }

  historyToggleBtn.addEventListener('click', () => toggleHistoryDrawer());
  closeHistoryBtn.addEventListener('click', () => toggleHistoryDrawer(false));
  drawerBackdropEl.addEventListener('click', () => toggleHistoryDrawer(false));
  clearHistoryBtn.addEventListener('click', () => {
    state.history = [];
    localStorage.removeItem('spidey_calc_history');
    renderHistory();
    playClearSound();
  });

  // ========================================================================
  // CONTROLS & SUIT SWITCHER
  // ========================================================================
  soundToggleBtn.addEventListener('click', () => {
    state.soundEnabled = !state.soundEnabled;
    soundToggleBtn.classList.toggle('active', state.soundEnabled);
    soundToggleBtn.querySelector('.btn-icon').textContent = state.soundEnabled ? '🔊' : '🔇';
    playClickSound();
  });

  modeToggleBtn.addEventListener('click', () => {
    state.sciMode = !state.sciMode;
    scientificPanelEl.classList.toggle('show', state.sciMode);
    modeToggleBtn.classList.toggle('active', state.sciMode);
    playClickSound();
  });

  suitButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      suitButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const suitName = btn.dataset.suit;
      document.body.className = `theme-${suitName}`;
      state.suit = suitName;
      playThwipSound();
    });
  });

  // ========================================================================
  // KEYPAD INTERACTION ENGINE
  // ========================================================================
  keys.forEach(key => {
    key.addEventListener('click', (e) => {
      const rect = key.getBoundingClientRect();
      createWebBurst(rect.left + rect.width / 2, rect.top + rect.height / 2);

      const val = key.dataset.val;
      const action = key.dataset.action;

      if (val !== undefined) {
        appendCharacter(val);
        playClickSound();
      } else if (action) {
        switch (action) {
          case 'clear-all': clearAll(); break;
          case 'clear-entry': clearEntry(); break;
          case 'backspace': backspace(); break;
          case 'equals': evaluateExpression(); break;
          case 'negate': handleNegate(); playClickSound(); break;
          case 'add': handleOperator('+'); playClickSound(); break;
          case 'subtract': handleOperator('−'); playClickSound(); break;
          case 'multiply': handleOperator('×'); playClickSound(); break;
          case 'divide': handleOperator('÷'); playClickSound(); break;
          case 'mod': handleOperator('%'); playClickSound(); break;
          case 'sqrt-quick': state.expression += '√('; renderDisplay(); playClickSound(); break;
          case 'square-quick': state.expression += '^2'; renderDisplay(); playClickSound(); break;
          default: handleSciFunction(action); break;
        }
      }
    });
  });

  // ========================================================================
  // KEYBOARD BINDINGS
  // ========================================================================
  window.addEventListener('keydown', (e) => {
    if (e.key >= '0' && e.key <= '9') {
      appendCharacter(e.key);
      playClickSound();
    } else if (e.key === '.') {
      appendCharacter('.');
      playClickSound();
    } else if (e.key === '+') {
      handleOperator('+');
      playClickSound();
    } else if (e.key === '-') {
      handleOperator('−');
      playClickSound();
    } else if (e.key === '*') {
      handleOperator('×');
      playClickSound();
    } else if (e.key === '/') {
      e.preventDefault();
      handleOperator('÷');
      playClickSound();
    } else if (e.key === '%') {
      handleOperator('%');
      playClickSound();
    } else if (e.key === 'Enter' || e.key === '=') {
      e.preventDefault();
      evaluateExpression();
    } else if (e.key === 'Backspace') {
      backspace();
    } else if (e.key === 'Escape') {
      clearAll();
    }
  });

  // Initial render
  renderDisplay();
});
