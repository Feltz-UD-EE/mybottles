import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "container", "template", "destroyField" ]

  add() {
    const id = new Date().getTime().toString()
    this.containerTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("NEW_RECORD", id))
  }

  remove(event) {
    const row = event.target.closest(".nested-fields-row")
    const destroyField = row.querySelector("input[name$='[_destroy]']")

    if (destroyField && row.querySelector("input[name$='[id]']")) {
      destroyField.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
