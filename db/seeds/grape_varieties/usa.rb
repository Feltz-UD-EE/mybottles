# Sources used while preparing this review seed:
# - California wine overview: https://en.wikipedia.org/wiki/California_wine
# - Zinfandel: https://en.wikipedia.org/wiki/Zinfandel
# - Norton grape references: https://en.wikipedia.org/wiki/Norton_(grape)
# - Marquette: https://en.wikipedia.org/wiki/Marquette_(grape)

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Baco noir", notes: "Hybrid red variety grown in cooler North American regions." },
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Catawba", notes: "American hybrid/labrusca wine grape historically used for sparkling and rosé wines." },
  { name: "Chardonnay", notes: nil },
  { name: "Chenin Blanc", notes: nil },
  { name: "Concord", notes: "American labrusca grape also used for wine." },
  { name: "Frontenac", notes: "Cold-hardy University of Minnesota hybrid." },
  { name: "Marquette", notes: "Cold-hardy University of Minnesota hybrid introduced in 2006." },
  { name: "Merlot", notes: nil },
  { name: "Mission", notes: "Historic Spanish-introduced variety also related to País and Criolla Chica." },
  { name: "Norton", notes: "American red wine grape associated with Missouri and Virginia." },
  { name: "Petit Verdot", notes: nil },
  { name: "Petite Sirah", notes: "Common name used for Durif in California." },
  { name: "Pinot Gris", notes: nil },
  { name: "Pinot Noir", notes: nil },
  { name: "Riesling", notes: nil },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Seyval Blanc", notes: "Hybrid white variety used in cooler eastern and midwestern regions." },
  { name: "Syrah", notes: nil },
  { name: "Tannat", notes: nil },
  { name: "Vidal blanc", notes: "Cold-hardy hybrid used for late-harvest and ice wine styles." },
  { name: "Viognier", notes: nil },
  { name: "Zinfandel", notes: "Croatian-origin variety strongly associated with California." }
])
