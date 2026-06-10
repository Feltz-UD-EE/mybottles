# Sources used while preparing this review seed:
# - Argentine wine overview: https://en.wikipedia.org/wiki/Argentine_wine
# - Torrontés: https://en.wikipedia.org/wiki/Torront%C3%A9s
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Bonarda", notes: "Important red variety; often associated with Argentine Bonarda/Douce Noir contexts." },
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Cereza", notes: "Pink-skinned Criolla-family grape historically important for bulk wine and concentrate." },
  { name: "Chardonnay", notes: nil },
  { name: "Criolla Chica", notes: "Historic Criolla-family grape related to País and Mission." },
  { name: "Criolla Grande", notes: "Pink-skinned Criolla-family grape historically important for bulk wine." },
  { name: "Malbec", notes: "Most prominent red variety for export-oriented premium wine." },
  { name: "Merlot", notes: nil },
  { name: "Pedro Giménez", notes: "White variety used for still and bulk wines; distinct from Spanish Pedro Ximénez." },
  { name: "Pinot Noir", notes: nil },
  { name: "Semillon", notes: nil },
  { name: "Syrah", notes: nil },
  { name: "Tempranillo", notes: nil },
  { name: "Torrontés Mendocino", notes: "One of the three Argentine Torrontés varieties." },
  { name: "Torrontés Riojano", notes: "Most important Argentine Torrontés variety for quality wine." },
  { name: "Torrontés Sanjuanino", notes: "One of the three Argentine Torrontés varieties." }
])
