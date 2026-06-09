# Geography seeds for use case 0008.
# This file is intentionally not required by db/seeds.rb yet; run only after review.

def seed_countries(rows)
  rows.each do |attributes|
    Country.find_or_initialize_by(iso3: attributes[:iso3]).tap do |country|
      country.assign_attributes(attributes)
      country.save!
    end
  end
end

def seed_appellations_for(country_iso3, rows)
  country = Country.find_by!(iso3: country_iso3)
  created_regions = {}
  remaining_regions = rows.dup

  until remaining_regions.empty?
    ready_regions, waiting_regions = remaining_regions.partition do |attributes|
      attributes[:parent].blank? || created_regions.key?(attributes[:parent])
    end
    raise "Unresolved parent regions: #{waiting_regions.map { |attributes| attributes[:parent] }.uniq.join(', ')}" if ready_regions.empty?

    ready_regions.each do |attributes|
      parent = created_regions[attributes[:parent]]
      region = Appellation.find_or_initialize_by(country: country, name: attributes[:name], parent: parent)
      region.assign_attributes(
        degree: attributes[:degree],
        auto_generated: true
      )
      region.save!
      created_regions[attributes[:name]] = region
    end

    remaining_regions = waiting_regions
  end
end

load Rails.root.join("db/seeds/geography/countries.rb")
Dir[Rails.root.join("db/seeds/geography/appellations/*.rb")].sort.each { |path| load path }
