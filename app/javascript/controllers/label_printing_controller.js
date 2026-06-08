import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]
  static values = {
    preferenceKey: { type: String, default: "my-bottles-print-labels" }
  }

  connect() {
    this.updateButton()
  }

  toggle() {
    localStorage.setItem(this.preferenceKeyValue, this.printLabels ? "no-labels" : "print-labels")
    this.updateButton()
  }

  updateButton() {
    this.buttonTarget.setAttribute("aria-pressed", String(this.printLabels))
    this.labelTarget.textContent = this.printLabels ? "No labels" : "Print labels"
  }

  get printLabels() {
    return localStorage.getItem(this.preferenceKeyValue) === "print-labels"
  }
}
