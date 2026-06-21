import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    enabled: Boolean,
    url: String
  }

  connect() {
    if (!this.enabledValue) return

    window.open(this.urlValue, "_blank", "noopener")
  }
}
