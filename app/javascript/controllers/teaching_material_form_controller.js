import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "questionImage"]

  questionImageTargetConnected() {
    this.questionImageTarget.addEventListener("change", this.handleImageChange.bind(this))
  }

  handleImageChange(event) {
    const titleField = this.titleTarget
    if (titleField.value.trim() === "") {
      const file = event.target.files[0]
      if (file) {
        // ファイル名から拡張子を除去して設定
        const nameWithoutExtension = file.name.replace(/\.[^/.]+$/, "")
        titleField.value = nameWithoutExtension
      }
    }
  }
}