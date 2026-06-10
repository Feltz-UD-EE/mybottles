# Sources used while preparing this review seed:
# - Syrah/Shiraz synonym context: https://en.wikipedia.org/wiki/Syrah
# - Zinfandel synonym context: https://en.wikipedia.org/wiki/Zinfandel
# - South African wine local cultivar names: https://en.wikipedia.org/wiki/South_African_wine
# - Tannat synonym context: https://en.wikipedia.org/wiki/Tannat
# - Australian, Austrian, French, German, Portuguese, Spanish, and New World grape variety review seed notes.
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

Current.user = User.system_administrator

GRAPE_SYNONYM_SEEDS = [
  [ "Altesse", "Roussette", "Savoie local name." ],
  [ "Blaufränkisch", "Lemberger", "German/Austrian name." ],
  [ "Carignan", "Cariñena", "French/Spanish name." ],
  [ "Carignan", "Mazuelo", "French/Spanish name." ],
  [ "Carmenère", "Carménère", "Accent spelling variant." ],
  [ "Chasselas", "Gutedel", "French/German name." ],
  [ "Chenin Blanc", "Steen", "Traditional South African name." ],
  [ "Crouchen", "Cape Riesling", "South African local name." ],
  [ "Durif", "Petite Sirah", "California common name." ],
  [ "Fer", "Braucol", "Southwest France local name." ],
  [ "Grenache", "Garnacha Tinta", "French/Spanish name." ],
  [ "Macabeo", "Viura", "Spanish regional name." ],
  [ "Malbec", "Cot", "Unaccented local name." ],
  [ "Malbec", "Côt", "French local name." ],
  [ "Mourvèdre", "Monastrell", "French/Spanish name." ],
  [ "Muscat of Alexandria", "Hanepoot", "South African local name." ],
  [ "Palomino", "White French", "South African local name." ],
  [ "Pinot Blanc", "Weißburgunder", "French/German name." ],
  [ "Pinot Gris", "Grauburgunder", "French/German name." ],
  [ "Pinot Gris", "Ruländer", "Traditional German name." ],
  [ "Pinot Noir", "Spätburgunder", "French/German name." ],
  [ "Semillon", "Groendruif", "South African local name." ],
  [ "Semillon", "Sémillon", "Accent spelling variant." ],
  [ "Syrah", "Shiraz", "Common name across wine-producing regions." ],
  [ "Tannat", "Harriague", "Uruguayan local name." ],
  [ "Tempranillo", "Aragonez", "Spanish/Portuguese name." ],
  [ "Tempranillo", "Tinta Roriz", "Spanish/Portuguese name." ],
  [ "Trebbiano", "Tália", "Italian/Portuguese name." ],
  [ "Trebbiano", "Ugni Blanc", "Italian/French name." ],
  [ "Trousseau", "Bastardo", "French/Portuguese name." ],
  [ "Vermentino", "Rolle", "Italian/French local name." ],
  [ "Welschriesling", "Welshriesling", "Spelling variant." ],
  [ "Zinfandel", "Primitivo", "American/Italian name." ],
  [ "Zweigelt", "Rotburger", "Official Austrian name." ]
].freeze

GRAPE_SYNONYM_SEEDS.each do |grape_name, synonym_name, notes|
  grape = Grape.find_by!(name: grape_name)
  synonym = Grape.find_by!(name: synonym_name)
  low, high = [ grape.id, synonym.id ].sort

  GrapeSynonym
    .where("LEAST(grape_id, synonym_grape_id) = ? AND GREATEST(grape_id, synonym_grape_id) = ?", low, high)
    .first_or_create!(grape: grape, synonym_grape: synonym, notes: notes)
end
