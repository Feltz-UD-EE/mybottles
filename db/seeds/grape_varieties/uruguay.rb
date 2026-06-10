# Sources used while preparing this review seed:
# - Uruguayan wine overview: https://en.wikipedia.org/wiki/Uruguayan_wine
# - Tannat: https://en.wikipedia.org/wiki/Tannat
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Albariño", notes: "Introduced by immigrants from Galicia in the 1950s." },
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Chardonnay", notes: nil },
  { name: "Harriague", notes: "Local synonym associated with Tannat." },
  { name: "Marselan", notes: nil },
  { name: "Merlot", notes: nil },
  { name: "Muscat Hamburg", notes: "Common variety for rosé table wines." },
  { name: "Pinot Noir", notes: nil },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Tannat", notes: "Nationally prominent red variety introduced by Basque settlers." }
])
