# Sources used while preparing this review seed:
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties
# - Bordeaux grape varieties: https://www.bordeaux.com/us/Our-Terroir/Grape-varieties
# - Bordeaux wine permitted grapes: https://en.wikipedia.org/wiki/Bordeaux_wine
# - Syrah/Shiraz synonym context: https://en.wikipedia.org/wiki/Syrah

Current.user = User.system_administrator

GRAPE_SEEDS = [
  [ "Aglianico", nil ],
  [ "Albariño", nil ],
  [ "Aligoté", nil ],
  [ "Arinarnoa", "Approved as an adaptation grape in some Bordeaux contexts." ],
  [ "Assyrtiko", nil ],
  [ "Barbera", nil ],
  [ "Blaufränkisch", nil ],
  [ "Cabernet Franc", "One of the permitted Bordeaux red grapes." ],
  [ "Cabernet Sauvignon", "One of the permitted Bordeaux red grapes." ],
  [ "Carménère", "One of the permitted Bordeaux red grapes." ],
  [ "Carignan", nil ],
  [ "Castets", "Approved as an adaptation grape in some Bordeaux contexts." ],
  [ "Chardonnay", nil ],
  [ "Chasselas", nil ],
  [ "Chenin Blanc", nil ],
  [ "Cinsault", nil ],
  [ "Colombard", "One of the permitted Bordeaux white grapes." ],
  [ "Corvina", nil ],
  [ "Dolcetto", nil ],
  [ "Fiano", nil ],
  [ "Furmint", nil ],
  [ "Gamay", nil ],
  [ "Garganega", nil ],
  [ "Gewürztraminer", nil ],
  [ "Grenache", nil ],
  [ "Grüner Veltliner", nil ],
  [ "Marsanne", nil ],
  [ "Marselan", "Approved as an adaptation grape in some Bordeaux contexts." ],
  [ "Malbec", "One of the permitted Bordeaux red grapes." ],
  [ "Melon de Bourgogne", nil ],
  [ "Merlot", "One of the permitted Bordeaux red grapes." ],
  [ "Merlot Blanc", "One of the permitted Bordeaux white grapes." ],
  [ "Monastrell", nil ],
  [ "Mourvèdre", nil ],
  [ "Muscadelle", "One of the permitted Bordeaux white grapes." ],
  [ "Nebbiolo", nil ],
  [ "Petit Manseng", "Approved as an adaptation grape in some Bordeaux contexts." ],
  [ "Petit Verdot", "One of the permitted Bordeaux red grapes." ],
  [ "Pinot Blanc", nil ],
  [ "Pinot Gris", nil ],
  [ "Pinot Meunier", nil ],
  [ "Pinot Noir", nil ],
  [ "Riesling", nil ],
  [ "Roussanne", nil ],
  [ "Sangiovese", nil ],
  [ "Sauvignon Blanc", "One of the permitted Bordeaux white grapes." ],
  [ "Sauvignon Gris", "One of the permitted Bordeaux white grapes." ],
  [ "Sémillon", "One of the permitted Bordeaux white grapes." ],
  [ "Shiraz", "Common synonym/name for Syrah." ],
  [ "Syrah", "Common synonym/name for Shiraz." ],
  [ "Tannat", nil ],
  [ "Tempranillo", nil ],
  [ "Touriga Nacional", "Approved as an adaptation grape in some Bordeaux contexts." ],
  [ "Trebbiano", nil ],
  [ "Ugni Blanc", "One of the permitted Bordeaux white grapes." ],
  [ "Verdejo", nil ],
  [ "Verdelho", nil ],
  [ "Vermentino", nil ],
  [ "Viognier", nil ],
  [ "Zinfandel", nil ]
].freeze

GRAPE_SEEDS.each do |name, notes|
  Grape.find_or_create_by!(name: name, notes: notes)
end
