def seed_grape_varieties(rows)
  Current.user = User.system_administrator

  rows.each do |attributes|
    grape = Grape.find_by(name: attributes.fetch(:name)) || Grape.new(name: attributes.fetch(:name))
    grape.notes = attributes[:notes] if grape.notes.blank? && attributes[:notes].present?
    grape.save!
  end
end
