# Sources used while preparing this review seed:
# - New Zealand wine overview: https://en.wikipedia.org/wiki/New_Zealand_wine
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Albariño", notes: nil },
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Chardonnay", notes: "Important in Hawke's Bay, Gisborne, and other regions." },
  { name: "Gewürztraminer", notes: nil },
  { name: "Merlot", notes: nil },
  { name: "Pinot Gris", notes: nil },
  { name: "Pinot Noir", notes: "Major red variety, especially in Central Otago, Martinborough, and Waipara." },
  { name: "Riesling", notes: nil },
  { name: "Sauvignon Blanc", notes: "Dominant variety, especially associated with Marlborough." },
  { name: "Syrah", notes: "Important in Hawke's Bay and Waiheke Island." }
])
