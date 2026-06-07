#!/usr/bin/env ruby

require "csv"
require "fileutils"

INPUT_PATH = ARGV.fetch(0)
OUTPUT_PATH = ARGV.fetch(1)
CSV_HEADERS = %w[
  personal_inventory
  date
  setting
  temperature
  pairing
  color
  nose
  palate
  overall
  score
  buy
].freeze

MONTH_PATTERN = /
  Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|
  Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?
/ix
DATE_PATTERNS = [
  /\b\d{4}[-\/]\d{1,2}[-\/]\d{1,2}\b/,
  /\b\d{4}[-\/]\d{1,2}\b/,
  /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b/,
  /\b\d{1,2}\/\d{1,2}\b/,
  /\b#{MONTH_PATTERN}\s+\d{1,2}\s+&\s+\d{1,2}\s+\d{4}\b/i,
  /\b\d{1,2}\s+#{MONTH_PATTERN}\s+\d{4}\b/i,
  /\b\d{1,2}\s+#{MONTH_PATTERN}\b/i,
  /\b#{MONTH_PATTERN}\s+\d{1,2},?\s+\d{4}\b/i,
  /\b#{MONTH_PATTERN}\s+\d{1,2}\b/i,
  /\b#{MONTH_PATTERN}\s+\d{4}\b/i,
  /\b\d{4}\s+#{MONTH_PATTERN}\b/i,
  /\b#{MONTH_PATTERN}\b/i
].freeze
EXCEL_DATE_SERIAL_PATTERN = /\b[34]\d{4}(?:\.0)?\b/
COLOR_PATTERN = /\b(?:color|colour)\b/i
NOSE_PATTERN = /\b(nose|aroma|aromas|aromatic|bouquet|smell)\b/i
BUY_PATTERN = /\b(buy again|buy more|purchase again|get more|get another|would buy|recommended|highly recommended|visit again)\b/i
NEGATIVE_BUY_PATTERN = /\b(don'?t buy|do not buy|not recommended|would not buy|nope)\b/i
COMMENTARY_START_PATTERN = /
  \b(
    a\ little|also|big|but|buy|clashed|could|delicious|drink|eh|excellent|fantastic|
    find|good|great|huge|light|lost|lovely|nice|nope|not|ok|outstanding|pretty|
    probably|quite|really|recommended|rougher|so-so|still|surpisingly|surprisingly|
    too|v\.?|very|vg|waiting|wonderful
  )\b
/ix

def clean(value)
  text = value.to_s.strip
  text.empty? ? nil : text
end

def normalize_text(value)
  value
    .to_s
    .gsub(/\s+/, " ")
    .gsub(/\s+([.,;:!?])/, '\1')
    .gsub(/\A[\s,.;:-]+|[\s,.;:-]+\z/, "")
    .strip
end

def strip_dates(value)
  text = value.to_s.dup
  DATE_PATTERNS.each { |pattern| text.gsub!(pattern, " ") }
  text.gsub!(EXCEL_DATE_SERIAL_PATTERN, " ")
  normalize_text(text)
end

def sentence_fragments(text)
  clean(text).to_s.split(/(?<=[.!?])\s+|;\s+/).map { |fragment| normalize_text(fragment) }.reject(&:empty?)
end

def extract_matching_text(text, pattern)
  matches = sentence_fragments(text).select { |sentence| sentence.match?(pattern) }
  clean(matches.join(" "))
end

def split_pairing_and_comment(text)
  phrase = normalize_text(text)
  return [ nil, nil ] if phrase.empty?

  phrase = phrase
    .gsub(/\b(?:and|then|also)\s+(?:with|w\/|in\/with|in and with)\s+/i, "; ")
    .gsub(/\bin\/with\s+/i, "")
    .gsub(/\bin and with\s+/i, "")
  phrase = normalize_text(phrase)

  split = phrase.match(/(.+?)(?:,\s+|\s+-\s+)(#{COMMENTARY_START_PATTERN}.*)\z/i)
  return [ normalize_text(split[1]), normalize_text(split[2]) ] if split

  [ phrase, nil ]
end

def pairing_fragment?(fragment)
  fragment.match?(/\bw\/\b/i) ||
    fragment.match?(/\bw\//i) ||
    fragment.match?(/\b(?:with|in\/with|in and with|in|into|turn(?:ed)?\s+into)\b/i) ||
    fragment.match?(/\b(?:white\s+)?sangria\b/i)
end

def extract_inline_pairings(fragment)
  connector_pattern = /(?:\bwith\b|w\/|\bin\/with\b|\bin and with\b|\bin\b|\binto\b|\bturn(?:ed)?\s+into\b)/i
  first_connector = fragment.match(connector_pattern)
  return nil unless first_connector

  prefix = normalize_text(fragment[0...first_connector.begin(0)])
  remainder = fragment[first_connector.begin(0)..]
  pairings = []
  comments = []

  remainder.scan(/(?:\bwith\b|w\/|\bin\/with\b|\bin and with\b|\bin\b|\binto\b|\bturn(?:ed)?\s+into\b)\s+(.+?)(?=(?:\s+(?:and|then|also)\s+(?:with|w\/|in\/with|in and with|in)\b)|\z)/i) do |match|
    pairing, comment = split_pairing_and_comment(match.first)
    pairings << pairing if pairing
    comments << comment if comment
  end

  comments.unshift(prefix) unless prefix.empty?
  [ pairings, comments ]
end

def extract_pairing_and_overall(text)
  pairings = []
  overall_fragments = []

  sentence_fragments(strip_dates(text)).each do |fragment|
    if pairing_fragment?(fragment) && (inline_pairings = extract_inline_pairings(fragment))
      pairings.concat(inline_pairings.first)
      overall_fragments.concat(inline_pairings.last)
    elsif fragment.match?(/\A(?:white\s+)?sangria\??\z/i)
      pairings << fragment
    else
      overall_fragments << fragment
    end
  end

  [ clean(pairings.join("; ")), clean(overall_fragments.join(" ")) ]
end

def buy_again?(text)
  normalized = clean(text).to_s
  return false if normalized.match?(NEGATIVE_BUY_PATTERN)

  normalized.match?(BUY_PATTERN)
end

tasting_note_rows = []

CSV.foreach(INPUT_PATH, headers: true) do |row|
  tasted = clean(row["tasted"])
  date = clean(row["disposal_date"])
  next if tasted.nil? || date.nil?

  pairing, overall = extract_pairing_and_overall(tasted)

  tasting_note_rows << {
    "personal_inventory" => clean(row["personal_inventory"]),
    "date" => date,
    "setting" => "Home",
    "temperature" => nil,
    "pairing" => pairing,
    "color" => extract_matching_text(overall, COLOR_PATTERN),
    "nose" => extract_matching_text(overall, NOSE_PATTERN),
    "palate" => nil,
    "overall" => overall,
    "score" => nil,
    "buy" => buy_again?(tasted) ? "true" : nil
  }
end

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
CSV.open(OUTPUT_PATH, "w", write_headers: true, headers: CSV_HEADERS) do |csv|
  tasting_note_rows.each { |row| csv << row }
end

puts "Wrote #{tasting_note_rows.size} tasting note rows to #{OUTPUT_PATH}"
