import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    this.modal = document.querySelector(this.element.dataset.modalTarget)
    
    if (this.modal) {
      this.modal.addEventListener('shown.bs.modal', () => {
        const radioButton = this.element.querySelector('input[type="radio"]')
        if (radioButton) radioButton.focus()
      })
    }
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd)
    if (this.modal) {
      this.modal.removeEventListener('shown.bs.modal', this.handleModalShow)
    }
  }

  handleSubmitEnd(event) {
    if (event.detail.success) {
      // 既存のメッセージを削除
      this.element.querySelectorAll('.alert').forEach(el => el.remove())

      const flashMessage = document.createElement('div')
      flashMessage.className = 'alert alert-success alert-dismissible fade show mt-3'
      flashMessage.innerHTML = `
        採点を保存しました
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      `
      this.element.insertAdjacentElement('afterbegin', flashMessage)

      // ラジオボタンの状態を更新
      const checkedInput = this.element.querySelector('input[name="grade[score]"]:checked')
      if (checkedInput) {
        this.element.querySelectorAll('.btn-check + label').forEach(label => {
          label.className = 'btn btn-outline-primary'
        })
        const selectedLabel = checkedInput.nextElementSibling
        if (selectedLabel) {
          selectedLabel.className = 'btn btn-primary'
        }
      }
      
      setTimeout(() => {
        flashMessage.remove()
      }, 3000)
    }
  }

  handleModalShow = () => {
    const radioButton = this.element.querySelector('input[type="radio"]')
    if (radioButton) radioButton.focus()
  }
}