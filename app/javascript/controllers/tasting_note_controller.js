import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "vintageInput", "tasteableId", "vintageResults", "vintageStatus",
    "newWineFields", "newWineButton", "ratingInput", "ratingOutput"
  ]

  connect() {
    this.updateRating()
    if (this.hasVintageResultsTarget) this.clearVintageResults()
  }

  disconnect() {
    clearTimeout(this.searchTimer)
    this.searchRequest?.abort()
  }

  queueVintageSearch() {
    this.tasteableIdTarget.value = ""
    this.clearVintageResults()

    const query = this.vintageInputTarget.value.trim()
    if (query.length < 2) return

    this.searchTimer = setTimeout(() => this.searchVintages(query), 250)
  }

  async searchVintages(query) {
    this.searchRequest = new AbortController()
    const { signal } = this.searchRequest
    const url = new URL(this.vintageInputTarget.dataset.searchUrl, window.location.origin)
    url.searchParams.set("q", query)
    this.vintageStatusTarget.textContent = "Searching for vintages…"

    try {
      const response = await fetch(url, { signal, headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error("Vintage search failed")

      const results = await response.json()
      if (signal.aborted) return

      this.vintageResultsTarget.replaceChildren(...results.map(({ id, label }) => {
        const item = document.createElement("li")
        const button = document.createElement("button")
        button.type = "button"
        button.className = "button"
        button.textContent = label
        button.dataset.action = "tasting-note#selectVintage"
        button.dataset.vintageId = id
        item.append(button)
        return item
      }))
      this.vintageStatusTarget.textContent = results.length
        ? `${results.length} matching vintages shown.`
        : "No matching vintages."
    } catch {
      if (!signal.aborted) this.vintageStatusTarget.textContent = "Search is unavailable. Try again."
    }
  }

  focusVintageResults() {
    this.vintageResultsTarget.querySelector("button")?.focus()
  }

  selectVintage(event) {
    const button = event.currentTarget
    this.tasteableIdTarget.value = button.dataset.vintageId
    this.vintageInputTarget.value = button.textContent
    this.clearVintageResults()
    this.newWineFieldsTarget.hidden = true
    this.newWineFieldsTarget.disabled = true
    this.newWineButtonTarget.setAttribute("aria-expanded", "false")
    this.vintageInputTarget.focus()
    this.vintageStatusTarget.textContent = "Vintage selected."
  }

  showNewWine() {
    this.clearVintageResults()
    this.tasteableIdTarget.value = ""
    this.vintageInputTarget.value = ""
    this.newWineFieldsTarget.hidden = false
    this.newWineFieldsTarget.disabled = false
    this.newWineButtonTarget.setAttribute("aria-expanded", "true")
    this.newWineFieldsTarget.querySelector("input").focus()
  }

  clearVintageResults() {
    clearTimeout(this.searchTimer)
    this.searchRequest?.abort()
    this.vintageResultsTarget.replaceChildren()
    this.vintageStatusTarget.textContent = ""
  }

  updateRating() {
    if (!this.hasRatingInputTarget || !this.hasRatingOutputTarget) return

    this.ratingOutputTarget.value = Number(this.ratingInputTarget.value).toLocaleString(undefined, {
      minimumFractionDigits: 0,
      maximumFractionDigits: 2
    })
  }
}
