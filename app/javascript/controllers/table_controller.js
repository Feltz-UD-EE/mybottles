import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "row", "pageLabel", "rowCount", "previousButton", "nextButton"]
  static values = {
    page: { type: Number, default: 1 },
    perPage: { type: Number, default: 25 },
    sortColumn: String,
    sortIndex: { type: Number, default: -1 },
    sortDirection: { type: String, default: "asc" }
  }

  connect() {
    this.prepareSortableHeaders()
    this.render()
  }

  search() {
    this.pageValue = 1
    this.render()
  }

  sort(event) {
    const header = event.currentTarget.closest("th")
    const column = event.currentTarget.dataset.tableColumn || ""
    const index = column ? -1 : header.cellIndex
    const sortKey = column || `column-${index}`

    if (this.currentSortKey === sortKey) {
      this.sortDirectionValue = this.sortDirectionValue === "asc" ? "desc" : "asc"
    } else {
      this.sortColumnValue = column
      this.sortIndexValue = index
      this.sortDirectionValue = "asc"
    }

    this.render()
  }

  prepareSortableHeaders() {
    this.element.querySelectorAll("thead th").forEach((header) => {
      if (header.querySelector("button")) return
      if (header.textContent.trim().length === 0) return

      header.classList.add("data-table__sortable-header")
      header.tabIndex = 0
      header.addEventListener("click", (event) => this.sort(event))
      header.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") return

        event.preventDefault()
        this.sort(event)
      })
    })
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

    this.updatePagination(pageCount, visibleRows.length)
  }

  updatePagination(pageCount, visibleRowCount) {
    if (this.hasPageLabelTarget) {
      this.pageLabelTarget.textContent = `Page ${this.pageValue} of ${pageCount}`
    }

    if (this.hasRowCountTarget) {
      this.rowCountTarget.textContent = `${visibleRowCount} ${visibleRowCount === 1 ? "row" : "rows"}`
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

    if (!this.sortColumnValue && this.sortIndexValue < 0) return rows

    return rows.sort((left, right) => {
      const leftValue = this.sortValue(left)
      const rightValue = this.sortValue(right)
      const result = leftValue.localeCompare(rightValue, undefined, { numeric: true, sensitivity: "base" })

      return this.sortDirectionValue === "asc" ? result : -result
    })
  }

  sortValue(row) {
    if (this.sortIndexValue >= 0) {
      return row.cells[this.sortIndexValue]?.textContent.trim() || ""
    }

    const cell = row.querySelector(`[data-table-sort-value="${this.sortColumnValue}"]`)
    return cell ? cell.textContent.trim() : ""
  }

  get currentSortKey() {
    return this.sortColumnValue || `column-${this.sortIndexValue}`
  }

  get pageStart() {
    return (this.pageValue - 1) * this.perPageValue
  }
}
