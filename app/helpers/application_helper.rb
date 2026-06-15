module ApplicationHelper
  def community_status_tag(record)
    return unless record.respond_to?(:status_tag)
    return if record.status_tag.blank?

    content_tag(:span, record.status_tag, class: "status-tag status-tag--#{record.approval_status.parameterize}")
  end

  def pending_edit_tag(record)
    return unless user_signed_in?
    return unless ProposedChange.pending.for_target(record).where(proposed_by_user: current_user).exists?

    content_tag(:span, "Your edit is awaiting review", class: "status-tag status-tag--pending")
  end

  def tasted_checkmark
    content_tag(:span, "✓", class: "tasted-checkmark", role: "img", aria: { label: "Tasted" })
  end

  def rating_circles(rating, title: nil, label: nil)
    return if rating.blank?

    value = BigDecimal(rating.to_s)
    display_value = value.round(2)
    title ||= display_value.to_s("F")
    label ||= "Rating #{display_value.to_s("F")} out of 5"

    content_tag(:span, class: "rating-circles", title: title, role: "img", aria: { label: label }) do
      safe_join(5.times.map do |index|
        fill = [[ (value - index) * 100, 0 ].max, 100 ].min
        content_tag(:span, "", class: "rating-circle", style: "--rating-fill: #{fill.to_f}%;")
      end)
    end
  end

  def review_record_path(record)
    case record
    when Producer then review_producer_path(record)
    when Wine then review_wine_path(record)
    when Vintage then review_vintage_path(record)
    when Grape then review_grape_path(record)
    when GrapeSynonym then review_grape_synonym_path(record)
    when AppellationGrape then review_appellation_grape_path(record)
    else raise ArgumentError, "unsupported review record"
    end
  end

  def approve_review_record_path(record)
    case record
    when Producer then approve_review_producer_path(record)
    when Wine then approve_review_wine_path(record)
    when Vintage then approve_review_vintage_path(record)
    when Grape then approve_review_grape_path(record)
    when GrapeSynonym then approve_review_grape_synonym_path(record)
    when AppellationGrape then approve_review_appellation_grape_path(record)
    else raise ArgumentError, "unsupported review record"
    end
  end

  def reject_review_record_path(record)
    case record
    when Producer then reject_review_producer_path(record)
    when Wine then reject_review_wine_path(record)
    when Vintage then reject_review_vintage_path(record)
    when Grape then reject_review_grape_path(record)
    when GrapeSynonym then reject_review_grape_synonym_path(record)
    when AppellationGrape then reject_review_appellation_grape_path(record)
    else raise ArgumentError, "unsupported review record"
    end
  end

  def merge_review_record_path(record)
    case record
    when Producer then merge_review_producer_path(record)
    when Wine then merge_review_wine_path(record)
    when Vintage then merge_review_vintage_path(record)
    when Grape then merge_review_grape_path(record)
    when GrapeSynonym then merge_review_grape_synonym_path(record)
    when AppellationGrape then merge_review_appellation_grape_path(record)
    else raise ArgumentError, "unsupported review record"
    end
  end

  def user_theme_class
    return "theme-dark" if current_user&.theme_preference == "Dark"
    return "" if current_user&.theme_preference == "Light"

    ""
  end
end
