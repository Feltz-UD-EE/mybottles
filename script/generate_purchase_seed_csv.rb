#!/usr/bin/env ruby

require "csv"
require "date"
require "fileutils"
require "rexml/document"

WORKBOOK_PATH = ARGV.fetch(0)
OUTPUT_PATH = ARGV.fetch(1)
WORKBOOK_DIR = File.directory?(WORKBOOK_PATH) ? WORKBOOK_PATH : File.dirname(WORKBOOK_PATH)
EXCEL_EPOCH = Date.new(1899, 12, 30)
MONTHS = {
  "jan" => 1, "january" => 1,
  "feb" => 2, "february" => 2,
  "mar" => 3, "march" => 3,
  "apr" => 4, "april" => 4,
  "may" => 5,
  "jun" => 6, "june" => 6,
  "jul" => 7, "july" => 7,
  "aug" => 8, "august" => 8,
  "sep" => 9, "sept" => 9, "september" => 9,
  "oct" => 10, "october" => 10,
  "nov" => 11, "november" => 11,
  "dec" => 12, "december" => 12
}.freeze
CSV_HEADERS = %w[
  source_sheet
  personal_inventory
  purchase_date
  producer_name
  wine_name
  vintage
  appellation
  purchase_source
  list_price
  discount_price
  notes
  tasted
  disposal_date
  disposal_method
].freeze

def xml_doc(path)
  REXML::Document.new(File.read(path))
end

def sheet_names
  doc = xml_doc(File.join(WORKBOOK_DIR, "xl", "workbook.xml"))
  doc.elements.to_a("//xmlns:sheet").map { |sheet| sheet.attributes["name"] }
end

def shared_strings
  path = File.join(WORKBOOK_DIR, "xl", "sharedStrings.xml")
  return [] unless File.exist?(path)

  doc = xml_doc(path)
  doc.elements.to_a("//xmlns:si").map do |si|
    si.elements.to_a(".//xmlns:t").map(&:text).join
  end
end

def column_index(cell_ref)
  letters = cell_ref[/\A[A-Z]+/]
  letters.chars.reduce(0) { |sum, char| (sum * 26) + char.ord - 64 } - 1
end

def excel_date(value)
  number = Float(value)
  return nil if number < 1

  EXCEL_EPOCH + number.to_i
rescue ArgumentError
  nil
end

def clean(value)
  return nil if value.nil?

  text = value.to_s.strip
  return nil if text.empty?

  text
end

def normalize_number(value)
  text = clean(value)
  return nil if text.nil? || text == "?"

  text = text.delete("$,")
  return nil unless text.match?(/\A-?\d+(\.\d+)?\z/)

  text
end

def normalize_text_number(value)
  text = clean(value)
  return nil if text.nil?

  text.match?(/\A\d+\.0\z/) ? text.to_i.to_s : text
end

def normalize_date(value)
  text = clean(value)
  return nil if text.nil? || text == "?"

  date = excel_date(text)
  return date.iso8601 if date && text.match?(/\A\d+(\.0)?\z/)

  [
    "%Y-%m-%d",
    "%Y/%m/%d",
    "%m/%d/%Y",
    "%m/%d/%y"
  ].each do |format|
    parsed = Date.strptime(text[/\d{1,4}[-\/]\d{1,2}[-\/]\d{1,4}/], format) rescue nil
    return parsed.iso8601 if parsed && parsed.year >= 1900
  end

  nil
end

def disposal_method(tasted)
  text = clean(tasted)
  return nil if text.nil?

  normalized = text.downcase
  return "Spoiled" if normalized.match?(/spoil|corked|cooked/)
  return "Sale" if normalized.match?(/\bsold\b|\bsale\b/)
  return "Gift" if normalized.match?(/\bgift\b|\bgave\b|\bgiven\b/)

  "Drink"
end

def month_number(name)
  MONTHS[name.to_s.downcase]
end

def parsed_date(year, month, day)
  return nil if year.to_i < 1900 || month.to_i < 1 || day.to_i < 1

  Date.new(year.to_i, month.to_i, day.to_i)
rescue Date::Error
  nil
end

def disposal_date(tasted, purchase_date)
  text = clean(tasted)
  return nil if text.nil?

  excel = excel_date(text)
  return excel.iso8601 if excel

  normalized = text.downcase
  purchase = Date.iso8601(purchase_date) if purchase_date

  if (match = normalized.match(/\b(20\d{2}|19\d{2})[-\/](\d{1,2})[-\/](\d{1,2})\b/))
    return parsed_date(match[1], match[2], match[3])&.iso8601
  end

  if (match = normalized.match(/\b(\d{1,2})[-\/](\d{1,2})[-\/](20\d{2}|19\d{2})\b/))
    return parsed_date(match[3], match[1], match[2])&.iso8601
  end

  if (match = normalized.match(/\b(20\d{2}|19\d{2})[-\/](\d{1,2})\b/))
    return parsed_date(match[1], match[2], 15)&.iso8601
  end

  month_pattern = MONTHS.keys.sort_by(&:length).reverse.join("|")

  if (match = normalized.match(/\b(#{month_pattern})\.?\s+(\d{1,2})(?:st|nd|rd|th)?[,]?\s+(20\d{2}|19\d{2})\b/))
    return parsed_date(match[3], month_number(match[1]), match[2])&.iso8601
  end

  if (match = normalized.match(/\b(\d{1,2})\s+(#{month_pattern})\.?\s+(20\d{2}|19\d{2})\b/))
    return parsed_date(match[3], month_number(match[2]), match[1])&.iso8601
  end

  if (match = normalized.match(/\b(#{month_pattern})\.?\s+(20\d{2}|19\d{2})\b/))
    return parsed_date(match[2], month_number(match[1]), 15)&.iso8601
  end

  if (match = normalized.match(/\b(20\d{2}|19\d{2})\s+(#{month_pattern})\.?\b/))
    return parsed_date(match[1], month_number(match[2]), 15)&.iso8601
  end

  if purchase && (match = normalized.match(/\b(#{month_pattern})\.?\s+(\d{1,2})(?:st|nd|rd|th)?\b/))
    date = parsed_date(purchase.year, month_number(match[1]), match[2])
    date = date.next_year if date && date < purchase
    return date&.iso8601
  end

  if purchase && (match = normalized.match(/\b(\d{1,2})\s+(#{month_pattern})\.?\b/))
    date = parsed_date(purchase.year, month_number(match[2]), match[1])
    date = date.next_year if date && date < purchase
    return date&.iso8601
  end

  nil
rescue Date::Error
  nil
end

def cell_value(cell, strings)
  type = cell.attributes["t"]
  value = cell.elements["xmlns:v"]&.text

  if type == "s"
    strings[value.to_i]
  elsif type == "inlineStr"
    cell.elements.to_a(".//xmlns:t").map(&:text).join
  else
    value
  end
end

def worksheet_rows(sheet_number, strings)
  doc = xml_doc(File.join(WORKBOOK_DIR, "xl", "worksheets", "sheet#{sheet_number}.xml"))

  doc.elements.to_a("//xmlns:row").map do |row|
    cells = {}
    row.elements.each("xmlns:c") do |cell|
      cells[column_index(cell.attributes["r"])] = clean(cell_value(cell, strings))
    end
    cells
  end
end

def header_index(rows)
  rows.find_index do |row|
    values = row.values.compact
    values.include?("ID") && values.include?("Brand") && values.include?("Tasted")
  end
end

def header_map(row)
  row.each_with_object({}) do |(index, value), map|
    map[value.to_s.downcase.strip] = index if value
  end
end

def row_value(row, map, header)
  row[map.fetch(header)]
end

def inventory_code(row, map, sheet_name)
  id = clean(row_value(row, map, "id"))
  next_column = map.fetch("id") + 1
  sequence = clean(row[next_column])
  sheet_prefix = sheet_name.match(/\A(Michigan|Retail) (20\d{2})\z/) do |match|
    "#{match[1] == "Michigan" ? "M" : "R"}#{match[2][-2..]}"
  end

  if sequence&.match?(/\A\d+(\.0)?\z/) && (id&.match?(/\A[MR]\d{2}-?\z/i) || (id.nil? && sheet_prefix))
    prefix = (id || sheet_prefix).delete_suffix("-").upcase
    "#{prefix}-#{sequence.to_i.to_s.rjust(3, "0")}"
  else
    id&.delete(" ")&.upcase
  end
end

strings = shared_strings
purchase_rows = []

sheet_names.each_with_index do |sheet_name, index|
  next unless sheet_name.match?(/\A(Michigan|Retail) 20\d{2}\z/)

  rows = worksheet_rows(index + 1, strings)
  header_row_index = header_index(rows)
  next unless header_row_index

  map = header_map(rows[header_row_index])

  rows[(header_row_index + 1)..].each do |row|
    producer_name = clean(row_value(row, map, "brand"))
    source_name = clean(row_value(row, map, "variety/name"))
    region = clean(row_value(row, map, "region"))
    inventory = inventory_code(row, map, sheet_name)
    next if inventory.nil? || producer_name.nil?
    next if source_name.nil? && region.nil?

    purchase_date = normalize_date(row_value(row, map, "purch date"))
    tasted = clean(row_value(row, map, "tasted"))
    method = disposal_method(tasted)
    disposed_on = disposal_date(tasted, purchase_date)
    if purchase_date && disposed_on && Date.iso8601(disposed_on) < Date.iso8601(purchase_date)
      disposed_on = purchase_date
    end
    vintage = normalize_text_number(row_value(row, map, "vintage")) || "NV"

    purchase_rows << {
      "source_sheet" => sheet_name,
      "personal_inventory" => inventory,
      "purchase_date" => purchase_date,
      "producer_name" => producer_name,
      "wine_name" => source_name || region,
      "vintage" => vintage,
      "appellation" => region,
      "purchase_source" => clean(row_value(row, map, "retailer")),
      "list_price" => normalize_number(row_value(row, map, "list price")),
      "discount_price" => normalize_number(row_value(row, map, "discounted price")),
      "notes" => clean(row_value(row, map, "notes")),
      "tasted" => tasted,
      "disposal_date" => disposed_on,
      "disposal_method" => method
    }
  end
end

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
CSV.open(OUTPUT_PATH, "w", write_headers: true, headers: CSV_HEADERS) do |csv|
  purchase_rows.sort_by { |row| row["personal_inventory"] }.each { |row| csv << row }
end

puts "Wrote #{purchase_rows.size} purchase rows to #{OUTPUT_PATH}"
