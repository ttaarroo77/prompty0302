import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("Tag controller connected")
  }

  delete(event) {
    event.preventDefault()

    if (confirm("このタグを削除してもよろしいですか？")) {
      const form = this.element
      form.requestSubmit()
    }
  }
} 