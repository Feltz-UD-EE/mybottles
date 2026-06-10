def seed_appellation_grapes_for(country_iso3, rows)
  Current.user = User.system_administrator
  country = Country.find_by!(iso3: country_iso3)

  rows.each do |attributes|
    appellation = Appellation.find_by!(country: country, name: attributes.fetch(:appellation))

    attributes.fetch(:grapes).each do |grape_name|
      grape = Grape.find_by!(name: grape_name)

      AppellationGrape.find_or_create_by!(appellation: appellation, grape: grape) do |appellation_grape|
        appellation_grape.notes = attributes[:notes]
      end
    end
  end
end
