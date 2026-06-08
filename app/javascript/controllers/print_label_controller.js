import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    enabled: Boolean,
    preferenceKey: { type: String, default: "my-bottles-print-labels" },
    url: String
  }

  connect() {
    if (!this.enabledValue) return
    if (localStorage.getItem(this.preferenceKeyValue) !== "print-labels") return

    window.open(this.urlValue, "_blank", "noopener")
  }
}
