import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "row", "pageLabel", "previousButton", "nextButton"]
  static values = {
    page: { type: Number, default: 1 },
    perPage: { type: Number, default: 25 },
    sortColumn: String,
    sortDirection: { type: String, default: "asc" }
  }

  connect() {
    this.render()
  }

  search() {
    this.pageValue = 1
    this.render()
  }

  sort(event) {
    const column = event.currentTarget.dataset.tableColumn
    if (!column) return

    if (this.sortColumnValue === column) {
      this.sortDirectionValue = this.sortDirectionValue === "asc" ? "desc" : "asc"
    } else {
      this.sortColumnValue = column
      this.sortDirectionValue = "asc"
    }

    this.render()
  }

  nextPage() {
    this.pageValue += 1
    this.render()
  }

  previousPage() {
    this.pageValue = Math.max(1, this.pageValue - 1)
    this.render()
  }

  render() {
    const query = this.hasQueryTarget ? this.queryTarget.value.toLowerCase() : ""
    const visibleRows = this.sortedRows.filter((row) => {
      return query.length === 0 || row.textContent.toLowerCase().includes(query)
    })
    const pageCount = Math.max(1, Math.ceil(visibleRows.length / this.perPageValue))

    this.pageValue = Math.min(this.pageValue, pageCount)
    this.rowTargets.forEach((row) => row.hidden = true)
    visibleRows.forEach((row) => row.parentElement.appendChild(row))

    visibleRows.slice(this.pageStart, this.pageStart + this.perPageValue).forEach((row) => {
      row.hidden = false
    })

    this.updatePagination(pageCount)
  }

  updatePagination(pageCount) {
    if (this.hasPageLabelTarget) {
      this.pageLabelTarget.textContent = `Page ${this.pageValue} of ${pageCount}`
    }

    if (this.hasPreviousButtonTarget) {
      this.previousButtonTarget.disabled = this.pageValue <= 1
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = this.pageValue >= pageCount
    }
  }

  get sortedRows() {
    const rows = [...this.rowTargets]

    if (!this.sortColumnValue) return rows

    return rows.sort((left, right) => {
      const leftValue = this.sortValue(left)
      const rightValue = this.sortValue(right)
      const result = leftValue.localeCompare(rightValue, undefined, { numeric: true, sensitivity: "base" })

      return this.sortDirectionValue === "asc" ? result : -result
    })
  }

  sortValue(row) {
    const cell = row.querySelector(`[data-table-sort-value="${this.sortColumnValue}"]`)
    return cell ? cell.textContent.trim() : ""
  }

  get pageStart() {
    return (this.pageValue - 1) * this.perPageValue
  }
}
