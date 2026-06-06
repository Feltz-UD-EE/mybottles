import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  toggle() {
    const expanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.buttonTarget.setAttribute("aria-expanded", String(!expanded))
    this.panelTarget.classList.toggle("primary-menu--open", !expanded)
  }

  ignorePlaceholder(event) {
    event.preventDefault()
  }
}
