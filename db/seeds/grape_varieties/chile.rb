# Sources used while preparing this review seed:
# - Carménère: https://en.wikipedia.org/wiki/Carm%C3%A9n%C3%A8re
# - País: https://en.wikipedia.org/wiki/Pais
# - Chilean wine overview: https://en.wikipedia.org/wiki/Chilean_wine
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Cabernet Franc", notes: nil },
  { name: "Cabernet Sauvignon", notes: nil },
  { name: "Carignan", notes: nil },
  { name: "Carménère", notes: "Emblematic red variety; historic Bordeaux grape rediscovered as distinct in the 1990s." },
  { name: "Chardonnay", notes: nil },
  { name: "Cot", notes: "Local/alternate labeling sometimes associated with Malbec." },
  { name: "Merlot", notes: nil },
  { name: "Pais", notes: "Historic red variety descended from Spanish colonial plantings." },
  { name: "Pedro Jiménez", notes: "White variety used in Chile; distinct labeling from Spanish Pedro Ximénez contexts." },
  { name: "Petit Verdot", notes: nil },
  { name: "Pinot Noir", notes: nil },
  { name: "Sauvignon Blanc", notes: nil },
  { name: "Semillon", notes: nil },
  { name: "Syrah", notes: nil }
])
