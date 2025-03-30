import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "questionImage", "correctAnswer", "dropZone"]

  questionImageTargetConnected() {
    this.questionImageTarget.addEventListener("change", this.handleImageChange.bind(this))
  }

  handleDragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add('bg-light')
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('bg-light')
  }

  handleDrop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('bg-light')

    const files = event.dataTransfer.files
    if (files.length > 0) {
      // ファイル入力にドロップされたファイルを設定
      this.questionImageTarget.files = files
      // 変更イベントを発火して既存の処理を実行
      this.questionImageTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }

  handleImageChange(event) {
    const titleField = this.titleTarget
    const correctAnswerField = this.correctAnswerTarget
    
    if (titleField.value.trim() === "" || correctAnswerField.value.trim() === "") {
      const file = event.target.files[0]
      if (file) {
        // ファイル名を_で分割
        const parts = file.name.split('_')
        
        if (parts.length > 1) {
          // 最後の部分から拡張子を除去して正答に設定
          const lastPart = parts.pop()
          const answer = lastPart.replace(/\.[^/.]+$/, "")
          
          // 残りの部分をタイトルに設定
          const title = parts.join('_')
          
          if (titleField.value.trim() === "") {
            titleField.value = title
          }
          
          if (correctAnswerField.value.trim() === "") {
            correctAnswerField.value = answer
          }
        } else {
          // _がない場合は従来通りファイル名から拡張子を除去してタイトルのみ設定
          if (titleField.value.trim() === "") {
            const nameWithoutExtension = file.name.replace(/\.[^/.]+$/, "")
            titleField.value = nameWithoutExtension
          }
        }
      }
    }
  }
}