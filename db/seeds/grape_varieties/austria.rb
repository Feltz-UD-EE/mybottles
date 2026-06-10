# Sources used while preparing this review seed:
# - Austrian Wine grape varieties: https://www.austrianwine.com/our-wine/grape-varieties
# - Wikipedia Austrian wine overview: https://en.wikipedia.org/wiki/Austrian_wine
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Blauburger", notes: "Austrian red crossing." },
  { name: "Blauer Portugieser", notes: "Common Austrian red variety." },
  { name: "Blauer Wildbacher", notes: "Red variety used for Schilcher in western Styria." },
  { name: "Blaufränkisch", notes: "Burgenland and other Austrian regions." },
  { name: "Blütenmuskateller", notes: "Fungus-resistant variety included in Austrian wine contexts." },
  { name: "Chardonnay", notes: "Also known locally as Morillon in parts of Styria." },
  { name: "Donauriesling", notes: "Fungus-resistant Austrian white variety." },
  { name: "Frühroter Veltliner", notes: "Austrian white variety." },
  { name: "Furmint", notes: "Burgenland; also important in Hungary." },
  { name: "Goldburger", notes: "Austrian white crossing." },
  { name: "Grauburgunder", notes: "Austrian and German name for Pinot Gris." },
  { name: "Grüner Veltliner", notes: "Most widely planted Austrian wine grape." },
  { name: "Jubiläumsrebe", notes: "Austrian crossing." },
  { name: "Müller-Thurgau", notes: "Also known as Rivaner." },
  { name: "Muskat Ottonel", notes: "Austrian aromatic white grape." },
  { name: "Muskateller", notes: "Austrian wine context for Muscat varieties." },
  { name: "Neuburger", notes: "Austrian white variety." },
  { name: "Rathay", notes: "Austrian red crossing." },
  { name: "Riesling", notes: "Wachau, Kamptal, Kremstal, and other Austrian regions." },
  { name: "Rotburger", notes: "Official Austrian name for Zweigelt." },
  { name: "Roter Veltliner", notes: "Austrian white variety." },
  { name: "Sankt Laurent", notes: "Austrian red variety." },
  { name: "Sauvignon Blanc", notes: "Styria and other Austrian regions." },
  { name: "Scheurebe", notes: "Also known in Austria as Sämling 88." },
  { name: "Schilcher", notes: "Styrian wine context associated with Blauer Wildbacher." },
  { name: "Syrah", notes: "Permitted in Austrian Qualitätswein contexts." },
  { name: "Traminer", notes: "Austrian aromatic grape family including Gewürztraminer/Roter Traminer." },
  { name: "Weißburgunder", notes: "Austrian and German name for Pinot Blanc." },
  { name: "Welschriesling", notes: "Austrian white variety unrelated to Riesling." },
  { name: "Welshriesling", notes: "Common spelling variant for Welschriesling." },
  { name: "Zierfandler", notes: "Thermenregion." },
  { name: "Zweigelt", notes: "Also officially named Rotburger." }
])
