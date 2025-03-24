import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.loadSelectedMaterials()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.addEventListener('change', () => this.saveSelectedMaterials())
    })
  }

  loadSelectedMaterials() {
    const selectedMaterials = JSON.parse(sessionStorage.getItem('selectedMaterials') || '[]')
    this.checkboxTargets.forEach(checkbox => {
      if (selectedMaterials.includes(checkbox.value)) {
        checkbox.checked = true
      }
    })
  }

  saveSelectedMaterials() {
    const selectedMaterials = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
    sessionStorage.setItem('selectedMaterials', JSON.stringify(selectedMaterials))
  }

  // フォーム送信時にsessionStorageをクリア
  clearStorage() {
    sessionStorage.removeItem('selectedMaterials')
  }
}