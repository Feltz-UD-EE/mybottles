import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["newProducerFields", "producerSelect"]

  showNewProducer() {
    if (this.hasNewProducerFieldsTarget) {
      this.newProducerFieldsTarget.hidden = false
    }

    if (this.hasProducerSelectTarget) {
      this.producerSelectTarget.value = ""
      this.producerSelectTarget.disabled = true
      this.producerSelectTarget.required = false
    }
  }
}
