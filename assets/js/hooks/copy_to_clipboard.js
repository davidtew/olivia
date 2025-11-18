/**
 * Copy to Clipboard Hook
 *
 * Copies the text content of the element with id "generated-prompt"
 * to the clipboard when the copy button is clicked.
 */
export const CopyToClipboard = {
  mounted() {
    this.el.addEventListener('click', (e) => {
      e.preventDefault()

      let text = null

      // Check if element has data-copy-text attribute
      if (this.el.dataset.copyText) {
        text = this.el.dataset.copyText
      } else {
        // Fallback to looking for generated-prompt element (legacy behavior)
        const promptElement = document.getElementById('generated-prompt')
        if (!promptElement) {
          console.error('No copy text found - neither data-copy-text attribute nor prompt element')
          return
        }
        text = promptElement.textContent || promptElement.innerText
      }

      if (!text) {
        console.error('No text to copy')
        return
      }

      // Modern clipboard API
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text)
          .then(() => {
            this.showSuccess()
          })
          .catch(err => {
            console.error('Failed to copy:', err)
            this.fallbackCopy(text)
          })
      } else {
        this.fallbackCopy(text)
      }
    })
  },

  showSuccess() {
    // Visual feedback
    const originalText = this.el.textContent
    this.el.textContent = '✓ Copied!'
    this.el.classList.add('text-green-600')

    setTimeout(() => {
      this.el.textContent = originalText
      this.el.classList.remove('text-green-600')
    }, 2000)
  },

  fallbackCopy(text) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.left = '-9999px'
    document.body.appendChild(textArea)
    textArea.select()

    try {
      document.execCommand('copy')
      this.showSuccess()
    } catch (err) {
      console.error('Fallback copy failed:', err)
    }

    document.body.removeChild(textArea)
  }
}
