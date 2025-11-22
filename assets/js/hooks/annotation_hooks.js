// Per-element hook - handles click selection for annotation
export const AnnotatableElement = {
  mounted() {
    this.handleClick = (event) => {
      if (!document.body.classList.contains("annotation-mode")) return;

      event.preventDefault();
      event.stopPropagation();

      const anchorKey = this.el.dataset.noteAnchor;
      let anchorMeta = {};

      try {
        anchorMeta = JSON.parse(this.el.dataset.anchorMeta || "{}");
      } catch (_) {}

      // Tell LiveView
      this.pushEvent("start_annotation", {
        anchor_key: anchorKey,
        anchor_meta: anchorMeta
      });

      // Tell the recorder UI
      window.dispatchEvent(new CustomEvent("anchor-selected", {
        detail: { anchorKey, anchorMeta, element: this.el }
      }));

      // Visual feedback
      document.querySelectorAll('.annotation-selected').forEach(el =>
        el.classList.remove('annotation-selected')
      );
      this.el.classList.add('annotation-selected');
    };

    this.el.addEventListener("click", this.handleClick);
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  }
};

// Global recorder hook - handles MediaRecorder + upload
export const AudioAnnotation = {
  mounted() {
    console.log('[AudioAnnotation] Hook mounted on:', this.el?.tagName, 'id:', this.el?.id);
    console.log('[AudioAnnotation] this.upload type:', typeof this.upload);
    console.log('[AudioAnnotation] this.pushEvent type:', typeof this.pushEvent);
    console.log('[AudioAnnotation] this.handleEvent type:', typeof this.handleEvent);

    if (typeof this.upload !== 'function') {
      console.error('[AudioAnnotation] WARNING: upload method not available!');
    }

    // Hook is on the form, find the file input for upload reference
    this.fileInput = this.el.querySelector('input[type="file"]');
    console.log('[AudioAnnotation] Found file input:', this.fileInput?.id);

    // Find the visual container for UI placement
    this.container =
      document.getElementById("annotation-recorder-container") ||
      this.el.closest("#annotation-recorder-container") ||
      this.el.parentElement;

    console.log('[AudioAnnotation] Using container:', this.container?.id);

    window.__audioAnnotationHookDebug = {
      hasUpload: typeof this.upload === 'function',
      hasPushEvent: typeof this.pushEvent === 'function',
      hasHandleEvent: typeof this.handleEvent === 'function',
      elId: this.el?.id,
      containerId: this.container?.id
    };

    this.mediaRecorder = null;
    this.chunks = [];
    this.currentAnchor = null;
    this.isRecording = false;
    this.recordingStartTime = null;
    this.timerInterval = null;

    // Listen for anchor selection
    this.onAnchorSelected = (event) => {
      this.currentAnchor = event.detail;
      this.updateStatus(`Selected: ${this.currentAnchor.anchorKey}`);

      // Use the globally found textForm instead of searching parent
      if (this.textForm) {
        const anchorKeyInput = this.textForm.querySelector('.annotation-anchor-key');
        const anchorMetaInput = this.textForm.querySelector('.annotation-anchor-meta');

        if (anchorKeyInput && anchorMetaInput) {
          anchorKeyInput.value = this.currentAnchor.anchorKey;
          anchorMetaInput.value = JSON.stringify(this.currentAnchor.anchorMeta);
        }

        // Auto-show form if in text mode
        if (this.annotationMode === 'text') {
          this.textForm.classList.remove('hidden');
        }
      }
    };
    window.addEventListener("anchor-selected", this.onAnchorSelected);

    // Listen for mode changes from LiveView
    this.handleEvent("annotation_mode_changed", ({ enabled }) => {
      console.log('[AudioAnnotation] Mode changed:', enabled);
      document.body.classList.toggle("annotation-mode", enabled);
      this.updateStatus(enabled ? "Click an element to annotate" : "Annotation mode off");
      if (this.uiContainer) {
        this.uiContainer.style.display = enabled ? "block" : "none";
        console.log('[AudioAnnotation] UI visibility set to:', enabled ? "block" : "none");
      } else {
        console.warn('[AudioAnnotation] uiContainer not found!');
      }
    });

    // Listen for upload progress/completion
    this.handleEvent("upload_progress", (data) => {
      console.log('[AudioAnnotation] Upload progress event:', data);
    });

    // Listen for saved notes to add markers
    this.handleEvent("note_created", ({ id, anchor_key, audio_url, type, content }) => {
      console.log('[AudioAnnotation] Note created:', id, anchor_key, type);

      this.addMarker(id, anchor_key, { type, audio_url, content });
      this.updateStatus("Note saved!");
      this.currentAnchor = null;
      // Remove selection highlight
      document.querySelectorAll('.annotation-selected').forEach(el =>
        el.classList.remove('annotation-selected')
      );
    });

    // Listen for deleted notes
    this.handleEvent("note_deleted", ({ id }) => {
      const marker = document.querySelector(`[data-marker-id="${id}"]`);
      if (marker) marker.remove();
    });

    // Load existing notes on mount
    this.handleEvent("load_existing_notes", ({ notes }) => {
      notes.forEach(note => {
        this.addMarker(note.id, note.anchor_key, {
          type: note.type,
          audio_url: note.audio_url,
          content: note.content
        });
      });
    });

    this.buildUI();
  },

  destroyed() {
    window.removeEventListener("anchor-selected", this.onAnchorSelected);
    if (this.uiContainer) this.uiContainer.remove();
    if (this.timerInterval) clearInterval(this.timerInterval);
  },

  buildUI() {
    console.log('[AudioAnnotation] Building UI...');
    const container = document.createElement("div");
    container.id = "annotation-recorder";
    container.innerHTML = `
      <div class="annotation-status">Click an element to annotate</div>
      <div class="annotation-controls">
        <button class="annotation-record-btn">🎤 Record</button>
        <span class="annotation-timer hidden">0:00</span>
      </div>
      <button class="annotation-toggle-mode-btn">📝 Switch to Text</button>
    `;

    // Styles
    container.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      z-index: 9999;
      background: rgba(0, 0, 0, 0.9);
      color: white;
      padding: 12px 16px;
      border-radius: 8px;
      font-size: 14px;
      display: none;
      font-family: system-ui, -apple-system, sans-serif;
    `;

    document.body.appendChild(container);
    this.uiContainer = container;
    console.log('[AudioAnnotation] UI built and appended to body');
    this.statusEl = container.querySelector(".annotation-status");
    this.timerEl = container.querySelector(".annotation-timer");
    this.recordBtn = container.querySelector(".annotation-record-btn");

    // Style the button
    this.recordBtn.style.cssText = `
      background: #4F46E5;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      margin-top: 8px;
    `;

    this.recordBtn.addEventListener("click", () => {
      if (!this.currentAnchor) {
        alert("Click on an element first");
        return;
      }
      if (this.isRecording) {
        this.stopRecording();
      } else {
        this.startRecording();
      }
    });

    // Find text form globally by ID instead of searching in parent
    this.textForm = document.getElementById("annotation-text-form");

    // Deriving other elements from the form itself
    this.textarea = this.textForm?.querySelector(".annotation-textarea");

    // The textInputContainer IS the form in the current HTML structure
    this.textInputContainer = this.textForm;
    this.toggleModeBtn = container.querySelector(".annotation-toggle-mode-btn");

    console.log('[AudioAnnotation] buildUI - Found textForm globally:', this.textForm);
    console.log('[AudioAnnotation] buildUI - Found textarea:', this.textarea);
    console.log('[AudioAnnotation] buildUI - Found textInputContainer:', this.textInputContainer);

    this.annotationMode = "voice";

    if (this.textarea) {
      this.textarea.style.cssText = `
        width: 100%;
        padding: 8px;
        border: 1px solid #d1d5db;
        border-radius: 4px;
        font-size: 14px;
        font-family: system-ui, -apple-system, sans-serif;
        resize: vertical;
      `;
    }

    // Add form submit handler for text annotations
    console.log('[AudioAnnotation] About to add form submit handler, this.textForm =', this.textForm);
    if (this.textForm) {
      console.log('[AudioAnnotation] Adding submit event listener to form');
      this.textForm.addEventListener("submit", (e) => {
        e.preventDefault();
        console.log('[AudioAnnotation] Text form submitted');

        if (!this.currentAnchor) {
          console.log('[AudioAnnotation] No anchor selected');
          return;
        }

        const text = this.textarea?.value || '';
        if (!text.trim()) {
          console.log('[AudioAnnotation] No text content');
          return;
        }

        console.log('[AudioAnnotation] Calling saveTextAnnotation with:', text);
        this.saveTextAnnotation(text);
      });
      console.log('[AudioAnnotation] Form submit listener added successfully');
    } else {
      console.log('[AudioAnnotation] WARNING: textForm not found, cannot add submit listener');
    }

    if (this.toggleModeBtn) {
      this.toggleModeBtn.style.cssText = `
        background: #6b7280;
        color: white;
        border: none;
        padding: 6px 12px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 12px;
        margin-top: 8px;
        width: 100%;
      `;

      this.toggleModeBtn.addEventListener("click", () => {
        this.toggleAnnotationMode();
      });
    }
  },

  toggleAnnotationMode() {
    if (this.annotationMode === "voice") {
      this.annotationMode = "text";
      this.recordBtn.parentElement.classList.add("hidden");
      this.textInputContainer.classList.remove("hidden");
      this.toggleModeBtn.textContent = "🎤 Switch to Voice";
    } else {
      this.annotationMode = "voice";
      this.recordBtn.parentElement.classList.remove("hidden");
      this.textInputContainer.classList.add("hidden");
      this.toggleModeBtn.textContent = "📝 Switch to Text";
    }
  },

  saveTextAnnotation(text) {
    if (!this.currentAnchor) return;

    this.pushEvent("save_text_annotation", {
      anchor_key: this.currentAnchor.anchorKey,
      anchor_meta: this.currentAnchor.anchorMeta,
      text_content: text
    });

    this.textarea.value = "";
    this.updateStatus("Saving text note...");
  },

  updateStatus(text) {
    if (this.statusEl) this.statusEl.textContent = text;
  },

  async startRecording() {
    if (this.isRecording) return;

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      // Determine supported mime type
      let mimeType = 'audio/webm';
      if (!MediaRecorder.isTypeSupported('audio/webm')) {
        mimeType = MediaRecorder.isTypeSupported('audio/ogg') ? 'audio/ogg' : 'audio/mp4';
      }

      this.mediaRecorder = new MediaRecorder(stream, { mimeType });
      this.chunks = [];

      this.mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) this.chunks.push(e.data);
      };

      this.mediaRecorder.onstop = () => {
        this.finishRecording();
        stream.getTracks().forEach(t => t.stop());
      };

      this.mediaRecorder.start(1000);
      this.isRecording = true;
      this.recordingStartTime = Date.now();
      this.recordBtn.textContent = "⏹ Stop";
      this.recordBtn.style.background = "#DC2626";
      this.timerEl.classList.remove("hidden");
      this.updateTimer();

      this.updateStatus("Recording...");

    } catch (err) {
      console.error("Mic error:", err);
      this.updateStatus("Microphone error - check permissions");
    }
  },

  updateTimer() {
    if (!this.isRecording) return;

    const elapsed = Math.floor((Date.now() - this.recordingStartTime) / 1000);
    const mins = Math.floor(elapsed / 60);
    const secs = elapsed % 60;
    this.timerEl.textContent = `${mins}:${secs.toString().padStart(2, '0')}`;

    // Max 5 minutes
    if (elapsed >= 300) {
      this.stopRecording();
      return;
    }

    requestAnimationFrame(() => this.updateTimer());
  },

  stopRecording() {
    if (!this.isRecording || !this.mediaRecorder) return;
    this.mediaRecorder.stop();
    this.isRecording = false;
    this.recordBtn.textContent = "🎤 Record";
    this.recordBtn.style.background = "#4F46E5";
    this.timerEl.classList.add("hidden");
    this.updateStatus("Processing...");
  },

  async finishRecording() {
    if (!this.chunks.length) {
      this.updateStatus("No audio captured");
      return;
    }

    const mimeType = this.mediaRecorder.mimeType || 'audio/webm';
    const blob = new Blob(this.chunks, { type: mimeType });

    // Determine file extension
    let ext = 'webm';
    if (mimeType.includes('ogg')) ext = 'ogg';
    else if (mimeType.includes('mp4')) ext = 'm4a';

    const filename = `note-${Date.now()}.${ext}`;

    console.log('[AudioAnnotation] Blob created:', filename, blob.size, 'bytes');
    console.log('[AudioAnnotation] Converting to base64...');

    this.updateStatus("Uploading...");

    try {
      const reader = new FileReader();

      reader.onload = () => {
        const base64Data = reader.result.split(',')[1];
        console.log('[AudioAnnotation] Base64 conversion complete, sending to server...');

        this.pushEvent("save_audio_blob", {
          blob: base64Data,
          mime_type: mimeType,
          filename: filename
        });
      };

      reader.onerror = () => {
        console.error('[AudioAnnotation] Failed to read blob');
        this.updateStatus("Failed to process audio");
      };

      reader.readAsDataURL(blob);
    } catch (err) {
      console.error('[AudioAnnotation] Error converting blob:', err);
      this.updateStatus("Failed to process audio");
    }
  },


  addMarker(id, anchorKey, noteData) {
    const element = document.querySelector(`[data-note-anchor="${anchorKey}"]`);
    if (!element) {
      console.warn(`Could not find element with anchor: ${anchorKey}`);
      return;
    }

    // Don't duplicate markers
    if (document.querySelector(`[data-marker-id="${id}"]`)) return;

    const { type, audio_url, content } = noteData;
    const isTextNote = type === "text";

    const marker = document.createElement("button");
    marker.className = "annotation-marker";
    marker.dataset.markerId = id;
    marker.innerHTML = isTextNote ? "💬" : "🎤";
    marker.title = isTextNote ? "View text note" : "Play annotation";

    marker.style.cssText = `
      position: absolute;
      top: 8px;
      right: 8px;
      width: 28px;
      height: 28px;
      background: ${isTextNote ? '#059669' : '#4F46E5'};
      border: none;
      border-radius: 50%;
      cursor: pointer;
      font-size: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
      z-index: 10;
    `;

    marker.addEventListener("click", (e) => {
      e.stopPropagation();
      e.preventDefault();

      if (isTextNote) {
        this.showTextNote(content?.text || "No content", marker);
      } else {
        this.playAudio(audio_url, marker);
      }
    });

    // Ensure parent has relative positioning
    const computed = window.getComputedStyle(element);
    if (computed.position === 'static') {
      element.style.position = 'relative';
    }

    element.appendChild(marker);
  },

  showTextNote(text, marker) {
    // Remove any existing viewer
    const existing = document.querySelector(".annotation-text-viewer");
    if (existing) existing.remove();

    const viewer = document.createElement("div");
    viewer.className = "annotation-text-viewer";
    viewer.innerHTML = `
      <div class="text-note-content" style="
        max-width: 300px;
        padding: 8px;
        font-size: 14px;
        line-height: 1.5;
        color: #1f2937;
      ">${text}</div>
      <button class="close-viewer" style="
        background: #DC2626;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 4px 8px;
        cursor: pointer;
        font-size: 12px;
        margin-top: 8px;
      ">Close</button>
    `;

    viewer.style.cssText = `
      position: absolute;
      top: 100%;
      right: 0;
      background: white;
      padding: 12px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      z-index: 100;
      margin-top: 4px;
    `;

    viewer.querySelector(".close-viewer").addEventListener("click", () => {
      viewer.remove();
    });

    marker.parentElement.appendChild(viewer);
  },

  playAudio(url, marker) {
    // Remove any existing player
    const existing = document.querySelector(".annotation-player");
    if (existing) existing.remove();

    const player = document.createElement("div");
    player.className = "annotation-player";
    player.innerHTML = `
      <audio controls autoplay src="${url}" style="height: 32px;"></audio>
      <button class="close-player" style="
        background: #DC2626;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 4px 8px;
        cursor: pointer;
        font-size: 12px;
      ">×</button>
    `;

    player.style.cssText = `
      position: absolute;
      top: 100%;
      right: 0;
      background: white;
      padding: 8px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      z-index: 100;
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 4px;
    `;

    player.querySelector(".close-player").addEventListener("click", () => {
      player.remove();
    });

    // Auto-remove when audio ends
    player.querySelector("audio").addEventListener("ended", () => {
      setTimeout(() => player.remove(), 1000);
    });

    marker.parentElement.appendChild(player);
  }
};
