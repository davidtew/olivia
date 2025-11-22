// Initialize annotation system without relying on LiveView hooks
// This is a workaround for hook initialization issues

export function initializeAnnotations() {
  console.log('[Annotations] Initializing annotation system...');

  // Wait for LiveView to connect
  window.addEventListener('phx:page-loading-stop', () => {
    setTimeout(() => {
      initAnnotationHooks();
    }, 100);
  });

  // Also initialize on page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAnnotationHooks);
  } else {
    initAnnotationHooks();
  }
}

function initAnnotationHooks() {
  // LiveView now mounts AudioAnnotation reliably, so we skip manual initialization
  const recorderUI = document.getElementById('annotation-recorder');
  if (recorderUI) {
    console.log('[Annotations] AudioAnnotation already mounted by LiveView');
    // Don't do manual initialization - LiveView is handling it
  } else {
    console.log('[Annotations] Waiting for LiveView to mount AudioAnnotation...');
    // LiveView will mount it shortly, don't interfere
  }

  // We still manually initialize AnnotatableElement hooks since those need manual setup
  const container = document.getElementById('annotation-recorder-container');
  if (container && !container._annotationInitialized) {
    // ENABLED: Manual initialization because LiveView hook mounting is unreliable
    console.log('[Annotations] Initializing AudioAnnotation manually');
    container._annotationInitialized = true;

    if (window.liveSocket && window.liveSocket.hooks && window.liveSocket.hooks.AudioAnnotation) {
      const hookDef = window.liveSocket.hooks.AudioAnnotation;

      // Get the actual upload form that has phx-hook="AudioAnnotation"
      const uploadForm = container.querySelector('#annotation-upload-form');
      if (!uploadForm) {
        console.error('[Annotations] Upload form not found in container');
        return;
      }

      const hookContext = {
        el: uploadForm,
        pushEvent: (event, payload) => {
          console.log('[Annotations] pushEvent called:', event, payload);
          const mainView = document.querySelector('[data-phx-main]');
          console.log('[Annotations] mainView:', mainView);

          if (mainView && window.liveSocket) {
            const view = window.liveSocket.getViewByEl(mainView);
            console.log('[Annotations] view:', view);

            if (view && view.pushEvent) {
              console.log('[Annotations] Calling view.pushEvent');
              view.pushEvent(event, payload);
            } else {
              console.error('[Annotations] view.pushEvent not available');
            }
          } else {
            console.error('[Annotations] mainView or liveSocket not found');
          }
        },
        handleEvent: (event, callback) => {
          window.addEventListener(`phx:${event}`, (e) => callback(e.detail));
        },
        upload: (name, files, callback) => {
          console.log('[Annotations] Manual upload called for:', name, files.length, 'files');

          const mainView = document.querySelector('[data-phx-main]');
          if (!mainView || !window.liveSocket) {
            console.error('[Annotations] LiveView not found');
            if (callback) callback({ error: 'LiveView not found' });
            return;
          }

          const view = window.liveSocket.getViewByEl(mainView);
          if (!view) {
            console.error('[Annotations] Could not get view instance');
            if (callback) callback({ error: 'View not found' });
            return;
          }

          const fileInput = container.querySelector('input[type="file"]');
          if (!fileInput) {
            console.error('[Annotations] File input not found');
            if (callback) callback({ error: 'File input not found' });
            return;
          }

          // Set files on the input
          const dt = new DataTransfer();
          files.forEach(file => dt.items.add(file));
          fileInput.files = dt.files;

          // Trigger change event to start LiveView upload
          const event = new Event('change', { bubbles: true });
          fileInput.dispatchEvent(event);

          console.log('[Annotations] File set on input, waiting for upload to complete...');

          // Poll to check if upload is complete
          let attempts = 0;
          const maxAttempts = 100; // 10 seconds max
          const checkInterval = setInterval(() => {
            attempts++;

            // Check if there are uploaded entries by looking at the LiveView state
            const uploads = view.getUploads?.(name);

            if (uploads && uploads.length > 0) {
              const entry = uploads[0];
              console.log('[Annotations] Upload progress:', entry.progress, '%, done:', entry.done);

              if (entry.done) {
                clearInterval(checkInterval);
                console.log('[Annotations] Upload complete!');
                if (callback) callback({ done: uploads });
              } else if (entry.error) {
                clearInterval(checkInterval);
                console.error('[Annotations] Upload error:', entry.error);
                if (callback) callback({ error: entry.error });
              }
            }

            if (attempts >= maxAttempts) {
              clearInterval(checkInterval);
              console.error('[Annotations] Upload timeout');
              if (callback) callback({ error: 'Upload timeout' });
            }
          }, 100);
        }
      };

      // Copy methods from hookDef
      Object.keys(hookDef).forEach(key => {
        if (typeof hookDef[key] === 'function' && key !== 'mounted' && key !== 'destroyed') {
          hookContext[key] = hookDef[key].bind(hookContext);
        }
      });

      // Mount the hook
      try {
        hookDef.mounted.call(hookContext);
        console.log('[Annotations] AudioAnnotation mounted successfully');
        uploadForm._hookContext = hookContext;
        uploadForm._annotationInitialized = true;
      } catch (error) {
        console.error('[Annotations] Error mounting AudioAnnotation:', error);
      }
    }
  }

  // Initialize AnnotatableElement hooks manually
  const annotatableElements = document.querySelectorAll('[data-note-anchor]');
  annotatableElements.forEach(el => {
    if (!el._annotationInitialized) {
      el._annotationInitialized = true;

      const handleClick = (event) => {
        if (!document.body.classList.contains('annotation-mode')) return;

        event.preventDefault();
        event.stopPropagation();

        const anchorKey = el.dataset.noteAnchor;
        let anchorMeta = {};
        try {
          anchorMeta = JSON.parse(el.dataset.anchorMeta || '{}');
        } catch (_) {}

        // Tell LiveView
        const mainView = document.querySelector('[data-phx-main]');
        if (mainView && window.liveSocket) {
          const view = window.liveSocket.getViewByEl(mainView);
          if (view && view.liveSocket && view.liveSocket.socket) {
            const topic = view.channel ? view.channel.topic : null;
            if (topic) {
              window.liveSocket.socket.channels
                .find(ch => ch.topic === topic)
                ?.push('event', {
                  type: 'start_annotation',
                  event: 'start_annotation',
                  value: { anchor_key: anchorKey, anchor_meta: anchorMeta }
                });
            }
          }
        }

        // Tell the recorder UI
        window.dispatchEvent(new CustomEvent('anchor-selected', {
          detail: { anchorKey, anchorMeta, element: el }
        }));

        // Visual feedback
        document.querySelectorAll('.annotation-selected').forEach(sel =>
          sel.classList.remove('annotation-selected')
        );
        el.classList.add('annotation-selected');
      };

      el.addEventListener('click', handleClick);
    }
  });

  if (annotatableElements.length > 0) {
    console.log(`[Annotations] Initialized ${annotatableElements.length} annotatable elements`);
  }
}
