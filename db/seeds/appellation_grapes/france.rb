# Sources used while preparing this review seed:
# - Bordeaux grape varieties: https://www.bordeaux.com/us/Our-Terroir/Grape-varieties
# - Bordeaux wine permitted grapes: https://en.wikipedia.org/wiki/Bordeaux_wine

Current.user = User.system_administrator

BORDEAUX_GRAPES = [
  "Cabernet Franc",
  "Cabernet Sauvignon",
  "Merlot",
  "Sauvignon Blanc",
  "Sémillon"
].freeze

bordeaux_regions = Appellation.where(name: "Bordeaux")

BORDEAUX_GRAPES.each do |grape_name|
  grape = Grape.find_by!(name: grape_name)

  bordeaux_regions.find_each do |appellation|
    AppellationGrape.find_or_create_by!(appellation: appellation, grape: grape) do |appellation_grape|
      appellation_grape.notes = "Minimum Bordeaux grape seed requested in use case 0012."
    end
  end
end
