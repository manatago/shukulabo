import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modalImage"]

  connect() {
    this.modal = new bootstrap.Modal(document.querySelector('#imageModal'))
  }

  show(event) {
    const imageUrl = event.currentTarget.getAttribute("data-full-url")
    console.log('Image URL:', imageUrl) // デバッグ用
    if (imageUrl) {
      this.modalImageTarget.src = imageUrl
      console.log('Modal image src set to:', this.modalImageTarget.src) // デバッグ用
      this.modal.show()
    }
  }
}