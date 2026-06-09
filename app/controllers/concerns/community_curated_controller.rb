module CommunityCuratedController
  extend ActiveSupport::Concern

  private

  def visible_scope(model_class)
    model_class.visible_to(current_user)
  end

  def handle_community_update(record, permitted_params)
    if current_user.reviewer? || record.created_by_user == current_user && !record.approved?
      record.update(permitted_params)
    else
      submit_proposed_change(record, permitted_params)
      true
    end
  end

  def submit_proposed_change(record, permitted_params)
    attrs = changed_attributes_for(record, permitted_params)
    return if attrs.empty?

    ProposedChange.create!(
      target: record,
      proposed_by_user: current_user,
      proposed_attributes: attrs,
      original_attributes: attrs.keys.index_with { |name| record.public_send(name) },
      action: "Update"
    )
  end

  def changed_attributes_for(record, permitted_params)
    permitted_params.to_h.select do |name, value|
      record.public_send(name).to_s != value.to_s
    end
  end

  def community_update_notice(record)
    if current_user.reviewer? || record.created_by_user == current_user && !record.approved?
      "#{record.class.model_name.human} was successfully updated."
    else
      "Your edit is awaiting review."
    end
  end
end
