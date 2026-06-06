import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]
  static classes = ["dark"]
  static values = {
    preferenceKey: { type: String, default: "my-bottles-theme" }
  }

  connect() {
    this.applyTheme(this.savedTheme || this.preferredTheme)
  }

  toggle() {
    this.applyTheme(this.darkMode ? "light" : "dark")
    localStorage.setItem(this.preferenceKeyValue, this.darkMode ? "dark" : "light")
  }

  applyTheme(theme) {
    this.element.classList.toggle(this.darkClass, theme === "dark")
    this.updateButton()
  }

  updateButton() {
    if (!this.hasButtonTarget) return

    this.buttonTarget.setAttribute("aria-pressed", String(this.darkMode))

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.darkMode ? "Light mode" : "Dark mode"
    }
  }

  get darkMode() {
    return this.element.classList.contains(this.darkClass)
  }

  get savedTheme() {
    return localStorage.getItem(this.preferenceKeyValue)
  }

  get preferredTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}
