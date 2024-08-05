# TODO: clean this up

# Examples ----
lad_reg <- fetch_ons_api_data(
  data_id = "LAD23_RGN23_EN_LU",
  query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json")
)


ward_lad_utla_reg_ctry <- fetch_ons_api_data(
  data_id = "WD23_LAD23_CTY23_OTH_UK_LU",
  query_params = list(
    where = "1=1",
    outFields = "*", # Could do this instead c("WD23CD", "WD23NM", "LAD23CD", "LAD23NM", "CTY23CD", "CTY23NM", "RGN23CD", "RGN23NM", "CTRY23CD", "CTRY23NM")
    outSR = "4326",
    f = "json"
  )
)

ward_pcon_lad_utla <- fetch_ons_api_data(
  data_id = "WD24_PCON24_LAD24_UTLA24_UK_LU",
  query_params = list(
    where = "1=1",
    outFields = "*", # Could do this instead c("WD23CD", "WD23NM", "LAD23CD", "LAD23NM", "CTY23CD", "CTY23NM", "RGN23CD", "RGN23NM", "CTRY23CD", "CTRY23NM")
    outSR = "4326",
    f = "json"
  )
)
