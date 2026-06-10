# Sources used while preparing this review seed:
# - South African wine overview: https://en.wikipedia.org/wiki/South_African_wine
# - Pinotage: https://en.wikipedia.org/wiki/Pinotage
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Cape Riesling", notes: "Local name used for Crouchen." },
  { name: "Chardonnay", notes: nil },
  { name: "Chenin Blanc", notes: "Also traditionally known locally as Steen." },
  { name: "Cinsault", notes: nil },
  { name: "Colombard", notes: nil },
  { name: "Crouchen", notes: "Known locally as Cape Riesling." },
  { name: "Groendruif", notes: "Local name used for Semillon." },
  { name: "Hanepoot", notes: "Local name associated with Muscat of Alexandria." },
  { name: "Merlot", notes: nil },
  { name: "Palomino", notes: "Known locally in some contexts as White French." },
  { name: "Pinotage", notes: "Signature red variety; Pinot Noir x Cinsault crossing created in 1925." },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Semillon", notes: "Known locally in some contexts as Groendruif." },
  { name: "Shiraz", notes: nil },
  { name: "Steen", notes: "Traditional local name for Chenin Blanc." },
  { name: "White French", notes: "Local name used for Palomino." }
])
