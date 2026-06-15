import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vintageInput", "tasteableId", "newWineFields", "ratingInput", "ratingOutput"]

  connect() {
    this.updateRating()
  }

  selectVintage() {
    if (!this.hasVintageInputTarget || !this.hasTasteableIdTarget) return

    const option = [...this.element.querySelectorAll("#vintage-options option")].find((candidate) => {
      return candidate.value === this.vintageInputTarget.value
    })

    this.tasteableIdTarget.value = option ? option.dataset.id : ""
  }

  showNewWine() {
    if (this.hasNewWineFieldsTarget) {
      this.newWineFieldsTarget.hidden = false
    }

    if (this.hasTasteableIdTarget) {
      this.tasteableIdTarget.value = ""
    }
  }

  updateRating() {
    if (!this.hasRatingInputTarget || !this.hasRatingOutputTarget) return

    this.ratingOutputTarget.value = Number(this.ratingInputTarget.value).toLocaleString(undefined, {
      minimumFractionDigits: 0,
      maximumFractionDigits: 2
    })
  }
}
