import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.setupCheckboxes()
  }

  getSelectedMaterials() {
    try {
      const stored = sessionStorage.getItem('selectedMaterials')
      if (!stored) return []
      
      // 文字列の場合は配列に変換
      if (typeof stored === 'string' && !stored.startsWith('[')) {
        return [stored.replace(/["\[\]]/g, '')]
      }
      
      return JSON.parse(stored)
    } catch (e) {
      console.error('Failed to parse selectedMaterials:', e)
      return []
    }
  }

  setupCheckboxes() {
    this.loadSelectedMaterials()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.addEventListener('change', () => this.saveSelectedMaterials())
    })
  }

  // Turboフレーム更新時にも呼び出される
  loadSelectedMaterials() {
    const selectedMaterials = this.getSelectedMaterials()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = selectedMaterials.includes(checkbox.value)
    })
    this.updateHiddenFields()
  }

  saveSelectedMaterials() {
    const selectedMaterials = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
    sessionStorage.setItem('selectedMaterials', JSON.stringify(selectedMaterials))
    this.updateHiddenFields()
  }

  // フォームの隠しフィールドを更新
  updateHiddenFields() {
    const selectedMaterials = this.getSelectedMaterials()
    const form = document.getElementById('homework_form')
    if (!form) return

    // 既存のコンテナを探すか新規作成
    let container = form.querySelector('.hidden-material-ids')
    if (!container) {
      container = document.createElement('div')
      container.className = 'hidden-material-ids'
      form.appendChild(container)
    }

    // コンテナをクリア
    container.innerHTML = ''

    // 選択された問題IDに対して隠しフィールドを作成
    selectedMaterials.forEach(materialId => {
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = 'teaching_material_ids[]'
      hiddenField.value = materialId
      container.appendChild(hiddenField)
    })
  }

  validateForm(event) {
    const selectedMaterials = this.getSelectedMaterials()
    if (selectedMaterials.length === 0) {
      event.preventDefault()
      alert('少なくとも1つの問題を選択してください。')
      return
    }
    // フォーム送信前に最後の更新
    this.updateHiddenFields()
  }

  // フォーム送信成功時にsessionStorageをクリア
  clearStorage() {
    // フォームのバリデーションが成功した場合のみクリア
    if (document.getElementById('homework_form').checkValidity()) {
      sessionStorage.removeItem('selectedMaterials')
    }
  }
}