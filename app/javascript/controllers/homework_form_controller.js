import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "group", "deadline"]

  connect() {
    this.updateTitle()
  }

  updateTitle() {
    const group = this.groupTarget
    const deadline = this.deadlineTarget
    
    if (group.value && deadline.value) {
      const groupName = group.selectedOptions[0].text
      const deadlineDate = new Date(deadline.value)
      const formattedDate = this.formatDate(deadlineDate)
      this.titleTarget.value = `${groupName}_${formattedDate}`
    }
  }

  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`
  }
}