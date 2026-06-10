# Sources used while preparing this review seed:
# - Vidal blanc: https://en.wikipedia.org/wiki/Vidal_blanc
# - Baco noir: https://en.wikipedia.org/wiki/Baco_noir
# - Marquette: https://en.wikipedia.org/wiki/Marquette_(grape)
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Baco noir", notes: "Hybrid red variety used in Ontario and other cool-climate regions." },
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Chardonnay", notes: nil },
  { name: "Frontenac", notes: "Cold-hardy hybrid used in colder regions." },
  { name: "Gamay", notes: nil },
  { name: "L'Acadie blanc", notes: "Hybrid white variety associated with Nova Scotia." },
  { name: "Marquette", notes: "Cold-hardy hybrid permitted in Ontario and British Columbia VQA contexts." },
  { name: "Merlot", notes: nil },
  { name: "Pinot Gris", notes: nil },
  { name: "Pinot Noir", notes: nil },
  { name: "Riesling", notes: nil },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Seyval Blanc", notes: "Hybrid white variety used in cool-climate wine regions." },
  { name: "Vidal blanc", notes: "Cold-hardy hybrid strongly associated with Canadian ice wine." }
])
