# Sources used while preparing this review seed:
# - DAC permitted-variety summaries: https://en.wikipedia.org/wiki/Districtus_Austriae_Controllatus
# - Austrian wine classification and DAC overview: https://en.wikipedia.org/wiki/Austrian_wine
# - Kremstal DAC permitted varieties: https://en.wikipedia.org/wiki/Kremstal_DAC
# - Weinviertel DAC permitted varieties: https://en.wikipedia.org/wiki/Weinviertel_DAC
# - Schilcherland/Weststeiermark DAC context: https://en.wikipedia.org/wiki/Schilcherland_DAC

load Rails.root.join("db/seeds/appellation_grape_seed_helpers.rb")

seed_appellation_grapes_for("AUT", [
  {
    appellation: "Carnuntum",
    grapes: [
      "Blaufränkisch",
      "Chardonnay",
      "Grüner Veltliner",
      "Pinot Blanc",
      "Zweigelt"
    ],
    notes: "Partial DAC review seed for Carnuntum white and red DAC varieties."
  },
  {
    appellation: "Eisenberg",
    grapes: [ "Blaufränkisch" ],
    notes: "Eisenberg DAC is Blaufränkisch-based."
  },
  {
    appellation: "Kamptal",
    grapes: [
      "Grüner Veltliner",
      "Riesling"
    ],
    notes: "Kamptal DAC varieties."
  },
  {
    appellation: "Kremstal",
    grapes: [
      "Grüner Veltliner",
      "Riesling"
    ],
    notes: "Kremstal DAC varieties."
  },
  {
    appellation: "Leithaberg",
    grapes: [
      "Blaufränkisch",
      "Chardonnay",
      "Grüner Veltliner",
      "Neuburger",
      "Pinot Blanc",
      "Pinot Noir",
      "St. Laurent",
      "Zweigelt"
    ],
    notes: "Partial DAC review seed for Leithaberg white and red DAC varieties."
  },
  {
    appellation: "Mittelburgenland",
    grapes: [ "Blaufränkisch" ],
    notes: "Mittelburgenland DAC is Blaufränkisch-based."
  },
  {
    appellation: "Neusiedlersee",
    grapes: [ "Zweigelt" ],
    notes: "Partial DAC review seed for dry Neusiedlersee DAC, which is Zweigelt-based."
  },
  {
    appellation: "Rosalia",
    grapes: [
      "Blaufränkisch",
      "Zweigelt"
    ],
    notes: "Rosalia DAC red varieties."
  },
  {
    appellation: "Südsteiermark",
    grapes: [
      "Chardonnay",
      "Gelber Muskateller",
      "Pinot Blanc",
      "Pinot Gris",
      "Riesling",
      "Sauvignon Blanc",
      "Traminer",
      "Welschriesling"
    ],
    notes: "Steiermark DAC family white varieties used for Südsteiermark DAC review seed."
  },
  {
    appellation: "Traisental",
    grapes: [
      "Grüner Veltliner",
      "Riesling"
    ],
    notes: "Traisental DAC varieties."
  },
  {
    appellation: "Vulkanland Steiermark",
    grapes: [
      "Chardonnay",
      "Gelber Muskateller",
      "Pinot Blanc",
      "Pinot Gris",
      "Riesling",
      "Sauvignon Blanc",
      "Traminer",
      "Welschriesling"
    ],
    notes: "Steiermark DAC family white varieties used for Vulkanland Steiermark DAC review seed."
  },
  {
    appellation: "Wachau",
    grapes: [
      "Chardonnay",
      "Frühroter Veltliner",
      "Grüner Veltliner",
      "Müller-Thurgau",
      "Muskat Ottonel",
      "Muskateller",
      "Neuburger",
      "Pinot Blanc",
      "Pinot Gris",
      "Pinot Noir",
      "Riesling",
      "Roter Veltliner",
      "Sauvignon Blanc",
      "St. Laurent",
      "Traminer",
      "Zweigelt"
    ],
    notes: "Partial DAC review seed for Wachau Gebietswein and Ortswein varieties."
  },
  {
    appellation: "Weinviertel",
    grapes: [ "Grüner Veltliner" ],
    notes: "Weinviertel DAC is Grüner Veltliner-based."
  },
  {
    appellation: "Weststeiermark",
    grapes: [ "Blauer Wildbacher" ],
    notes: "Weststeiermark/Schilcherland DAC is based on Blauer Wildbacher for Schilcher."
  }
])
