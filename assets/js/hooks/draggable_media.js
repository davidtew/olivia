export const DraggableMedia = {
  mounted() {
    console.log('DraggableMedia hook mounted on:', this.el)
    console.log('Dataset:', this.el.dataset)

    this.el.addEventListener('dragstart', (e) => {
      const mediaId = this.el.dataset.mediaId
      const imageUrl = this.el.dataset.imageUrl

      console.log('DRAGSTART - Setting data:', { mediaId, imageUrl })

      e.dataTransfer.setData('media-id', mediaId)
      e.dataTransfer.setData('image-url', imageUrl)
      e.dataTransfer.effectAllowed = 'copy'

      this.el.style.opacity = '0.5'
    })

    this.el.addEventListener('dragend', (e) => {
      console.log('DRAGEND event')
      this.el.style.opacity = '1'
    })
  }
}
