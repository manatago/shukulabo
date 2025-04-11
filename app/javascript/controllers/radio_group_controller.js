import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]

  connect() {
    // 初期状態で選択されているラジオボタンのラベルをアクティブに
    const checkedInput = this.element.querySelector('input[type="radio"]:checked')
    if (checkedInput) {
      const label = checkedInput.nextElementSibling
      if (label) {
        label.className = "btn btn-primary"
      }
    }
  }

  select(event) {
    if (!event.target) return

    // すべてのラベルをデフォルトスタイルに戻す
    this.labelTargets.forEach(label => {
      label.className = "btn btn-outline-primary"
    })

    // 選択されたラジオボタンに対応するラベルをアクティブスタイルに変更
    const selectedLabel = event.target.nextElementSibling
    if (selectedLabel) {
      selectedLabel.className = "btn btn-primary"
    }
  }
}