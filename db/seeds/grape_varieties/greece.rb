# Sources used while preparing this review seed:
# - Wines of Greece grape varieties: https://winesofgreece.org/varieties/
# - Wikipedia Greek wine overview: https://en.wikipedia.org/wiki/Greek_wine
# - Wikipedia list of grape varieties: https://en.wikipedia.org/wiki/List_of_grape_varieties

load Rails.root.join("db/seeds/grape_variety_seed_helpers.rb")

seed_grape_varieties([
  { name: "Agiorgitiko", notes: "Nemea and Peloponnese." },
  { name: "Aidani", notes: "Aegean Islands and Cyclades." },
  { name: "Assyrtiko", notes: "Santorini and other Greek regions." },
  { name: "Athiri", notes: "Aegean Islands and Dodecanese." },
  { name: "Avgoustiatis", notes: "Ionian Islands and western Greece." },
  { name: "Begleri", notes: "Aegean Islands." },
  { name: "Dafni", notes: "Crete." },
  { name: "Debina", notes: "Epirus; Zitsa." },
  { name: "Fileri", notes: "Peloponnese." },
  { name: "Kakotrygis", notes: "Corfu." },
  { name: "Kidonitsa", notes: "Peloponnese." },
  { name: "Kotsifali", notes: "Crete." },
  { name: "Krasato", notes: "Thessaly; Rapsani." },
  { name: "Liatiko", notes: "Crete." },
  { name: "Limnio", notes: "Northern Greece and Aegean Islands." },
  { name: "Malagousia", notes: "Macedonia and other Greek regions." },
  { name: "Mandilaria", notes: "Aegean Islands and Crete." },
  { name: "Mavro Kalavrytino", notes: "Peloponnese." },
  { name: "Mavrodaphne", notes: "Patras and Cephalonia." },
  { name: "Mavrotragano", notes: "Santorini." },
  { name: "Monemvasia", notes: "Cyclades and Paros." },
  { name: "Moschofilero", notes: "Mantinia and Peloponnese." },
  { name: "Moschomavro", notes: "Northern Greece." },
  { name: "Muscat Blanc", notes: "Samos, Patras, and other Greek appellation contexts." },
  { name: "Negoska", notes: "Northern Greece; Goumenissa." },
  { name: "Plyto", notes: "Crete." },
  { name: "Robola", notes: "Cephalonia." },
  { name: "Roditis", notes: "Peloponnese, Patras, and other Greek regions." },
  { name: "Romeiko", notes: "Crete." },
  { name: "Savatiano", notes: "Attica and Central Greece." },
  { name: "Sideritis", notes: "Peloponnese." },
  { name: "Stavroto", notes: "Thessaly; Rapsani." },
  { name: "Thrapsathiri", notes: "Crete." },
  { name: "Tsaoussi", notes: "Cephalonia." },
  { name: "Vidiano", notes: "Crete." },
  { name: "Vilana", notes: "Crete." },
  { name: "Vlachiko", notes: "Epirus." },
  { name: "Vostilidi", notes: "Ionian Islands." },
  { name: "Xinomavro", notes: "Naoussa, Amyndeon, Goumenissa, and Rapsani." }
])
