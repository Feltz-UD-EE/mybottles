# Sources used while preparing this review seed:
# - Bordeaux grape varieties: https://www.bordeaux.com/us/Our-Terroir/Grape-varieties
# - Bordeaux wine permitted grapes: https://en.wikipedia.org/wiki/Bordeaux_wine
# - Champagne wine grape varieties: https://en.wikipedia.org/wiki/Champagne
# - Chablis wine grape variety: https://en.wikipedia.org/wiki/Chablis_wine
# - Rhône appellation grape summaries: https://en.wikipedia.org/wiki/C%C3%B4tes_du_Rh%C3%B4ne_AOC

load Rails.root.join("db/seeds/appellation_grape_seed_helpers.rb")

seed_appellation_grapes_for("FRA", [
  {
    appellation: "Bordeaux",
    grapes: [
      "Cabernet Franc",
      "Cabernet Sauvignon",
      "Merlot",
      "Sauvignon Blanc",
      "Sémillon"
    ],
    notes: "Partial review seed for commonly permitted Bordeaux grapes."
  },
  {
    appellation: "Champagne",
    grapes: [
      "Chardonnay",
      "Pinot Meunier",
      "Pinot Noir"
    ],
    notes: "Partial review seed for the three primary Champagne grape varieties."
  },
  {
    appellation: "Chablis",
    grapes: [ "Chardonnay" ],
    notes: "Chablis is produced from Chardonnay."
  },
  {
    appellation: "Chablis Premier Cru",
    grapes: [ "Chardonnay" ],
    notes: "Chablis Premier Cru is produced from Chardonnay."
  },
  {
    appellation: "Chablis Grand Cru",
    grapes: [ "Chardonnay" ],
    notes: "Chablis Grand Cru is produced from Chardonnay."
  },
  {
    appellation: "Condrieu",
    grapes: [ "Viognier" ],
    notes: "Condrieu is produced from Viognier."
  },
  {
    appellation: "Cornas",
    grapes: [ "Syrah" ],
    notes: "Cornas is produced from Syrah."
  },
  {
    appellation: "Côte-Rôtie",
    grapes: [
      "Syrah",
      "Viognier"
    ],
    notes: "Côte-Rôtie red wines are Syrah-based, with Viognier permitted."
  },
  {
    appellation: "Hermitage",
    grapes: [
      "Marsanne",
      "Roussanne",
      "Syrah"
    ],
    notes: "Hermitage red wines are Syrah-based; Marsanne and Roussanne are used for white Hermitage and may appear in red blends."
  },
  {
    appellation: "Côtes du Rhône",
    grapes: [
      "Bourboulenc",
      "Carignan",
      "Cinsault",
      "Clairette",
      "Grenache",
      "Marsanne",
      "Marselan",
      "Mourvèdre",
      "Muscardin",
      "Picpoul",
      "Roussanne",
      "Syrah",
      "Terret Noir",
      "Ugni Blanc",
      "Viognier"
    ],
    notes: "Partial review seed from published Côtes du Rhône permitted grape summaries; color-specific forms are collapsed where the grape seed uses the broader display name."
  }
])
