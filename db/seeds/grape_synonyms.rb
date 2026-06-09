# Sources used while preparing this review seed:
# - Syrah/Shiraz synonym context: https://en.wikipedia.org/wiki/Syrah
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

Current.user = User.system_administrator

GRAPE_SYNONYM_SEEDS = [
  [ "Syrah", "Shiraz", "Common synonym relationship used across wine-producing regions." ],
  [ "Mourvèdre", "Monastrell", "Common synonym relationship used across French and Spanish contexts." ],
  [ "Trebbiano", "Ugni Blanc", "Common synonym relationship used across Italian and French contexts." ]
].freeze

GRAPE_SYNONYM_SEEDS.each do |grape_name, synonym_name, notes|
  grape = Grape.find_by!(name: grape_name)
  synonym = Grape.find_by!(name: synonym_name)
  low, high = [ grape.id, synonym.id ].sort

  GrapeSynonym
    .where("LEAST(grape_id, synonym_grape_id) = ? AND GREATEST(grape_id, synonym_grape_id) = ?", low, high)
    .first_or_create!(grape: grape, synonym_grape: synonym, notes: notes)
end
