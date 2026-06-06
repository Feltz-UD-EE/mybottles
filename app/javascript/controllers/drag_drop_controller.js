import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  dragover(event) {
    event.preventDefault()
    this.element.classList.add(this.activeClassName)
  }

  dragleave() {
    this.element.classList.remove(this.activeClassName)
  }

  drop(event) {
    event.preventDefault()
    this.element.classList.remove(this.activeClassName)
    this.dispatch("drop", { detail: { files: event.dataTransfer.files } })
  }

  get activeClassName() {
    return this.hasActiveClass ? this.activeClass : "drop-zone--active"
  }
}
