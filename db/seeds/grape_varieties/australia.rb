# Sources used while preparing this review seed:
# - List of Australian wine grape varieties: https://en.wikipedia.org/wiki/List_of_Australian_wine_grape_varieties
# - Australian wine overview: https://en.wikipedia.org/wiki/Australian_wine
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Arneis", notes: nil },
  { name: "Barbera", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Chardonnay", notes: nil },
  { name: "Cienna", notes: "Australian-bred red grape variety." },
  { name: "Fiano", notes: nil },
  { name: "Grenache", notes: nil },
  { name: "Malbec", notes: nil },
  { name: "Marsanne", notes: nil },
  { name: "Merlot", notes: nil },
  { name: "Mourvèdre", notes: nil },
  { name: "Muscat of Alexandria", notes: nil },
  { name: "Nebbiolo", notes: nil },
  { name: "Petit Verdot", notes: nil },
  { name: "Pinot Gris", notes: nil },
  { name: "Pinot Noir", notes: nil },
  { name: "Riesling", notes: nil },
  { name: "Sangiovese", notes: nil },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Semillon", notes: nil },
  { name: "Shiraz", notes: "Dominant red variety; Australian name for Syrah." },
  { name: "Tarrango", notes: "Australian-bred red grape variety." },
  { name: "Tempranillo", notes: nil },
  { name: "Vermentino", notes: nil },
  { name: "Viognier", notes: nil }
])
