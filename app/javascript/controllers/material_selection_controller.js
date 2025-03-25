import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectedList"]

  connect() {
    this.setupCheckboxes()
    this.updateList()
  }

  getStoredMaterials() {
    try {
      const stored = sessionStorage.getItem('selectedMaterials')
      return stored ? JSON.parse(stored) : []
    } catch (e) {
      console.error('Failed to parse selectedMaterials:', e)
      return []
    }
  }

  setupCheckboxes() {
    const stored = this.getStoredMaterials()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = stored.includes(checkbox.value)
      checkbox.addEventListener('change', e => this.handleChange(e))
    })
  }

  updateList() {
    const materials = this.getStoredMaterials()
    
    if (materials.length === 0) {
      this.selectedListTarget.innerHTML = '<div class="text-muted">問題を選択してください</div>'
      return
    }

    const listItems = materials.map((id, index) => {
      const checkbox = document.getElementById(`material_${id}`)
      return `
        <div class="d-flex align-items-center mb-2">
          <span class="badge bg-secondary me-2">${index + 1}</span>
          <span class="me-2">問題ID: ${id}</span>
          <button type="button" class="btn btn-sm btn-outline-danger"
                  onclick="document.getElementById('material_${id}').click()">
            削除
          </button>
        </div>
      `
    }).join('')

    this.selectedListTarget.innerHTML = listItems
  }

  handleChange(event) {
    if (!event?.target) return

    const checkbox = event.target
    let materials = this.getStoredMaterials()

    if (checkbox.checked) {
      // チェックが入った場合は末尾に追加（重複を防ぐ）
      materials = [...new Set([...materials, checkbox.value])]
    } else {
      // チェックが外れた場合は配列から削除
      materials = materials.filter(id => id !== checkbox.value)
    }

    // セッションストレージを更新
    sessionStorage.setItem('selectedMaterials', JSON.stringify(materials))

    // UI更新
    this.updateList()
    this.updateHiddenFields(materials)
  }

  // フォームの隠しフィールドを更新
  updateHiddenFields(materials = null) {
    const selectedMaterials = materials || this.getStoredMaterials()
    const form = document.getElementById('homework_form')
    if (!form) return

    // 既存のコンテナを削除
    const existingContainer = form.querySelector('.hidden-material-ids')
    if (existingContainer) {
      existingContainer.remove()
    }

    // 新しいコンテナを作成
    const container = document.createElement('div')
    container.className = 'hidden-material-ids'
    
    // セッションストレージの値を使用して隠しフィールドを作成（順序を維持）
    selectedMaterials.forEach(materialId => {
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = 'teaching_material_ids[]'
      hiddenField.value = materialId
      container.appendChild(hiddenField)
    })

    form.appendChild(container)
  }

  validateForm(event) {
    const materials = this.getStoredMaterials()
    if (materials.length === 0) {
      event.preventDefault()
      alert('少なくとも1つの問題を選択してください。')
      return
    }
    // フォーム送信前に最後の更新
    this.updateHiddenFields(materials)
  }

  // フォーム送信成功時にsessionStorageをクリア
  clearStorage() {
    // フォームのバリデーションが成功した場合のみクリア
    if (document.getElementById('homework_form').checkValidity()) {
      sessionStorage.removeItem('selectedMaterials')
    }
  }
}