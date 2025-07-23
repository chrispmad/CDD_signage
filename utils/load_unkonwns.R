
unknowns<-locations |>
  filter(Installed_Y_N_U == "U")
# now we convert anything in easting northing to Lat Lon - first get the ones with easting northing
east_north<- unknowns |>
  filter(!is.na(Easting))

east_north <- east_north |>
  mutate(
    Longitude = Easting,
    Latitude = Northing
  ) |>
  select(-Easting, -Northing)

#create an sf object and convert to WGS84
east_north_sf <- st_as_sf(east_north, coords = c("Longitude", "Latitude"), crs = 32611) |>
  st_transform(4326)

longlat<- unknowns |>
  filter(!is.na(Longitude))

longlat_sf<- longlat |>
  mutate(
    Latitude = Latitude,
    Longitude = Longitude
  ) |>
  select(-Easting, -Northing) |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

#now combine these
signs_sf_unkonwns <- rbind(east_north_sf, longlat_sf)
# clean up sign type
signs_sf_unkonwns <- signs_sf_unkonwns |>
  mutate(Sign_Acronym = sub("^([A-Z]+).*", "\\1", Sign_Type))
# join on the meaning
signs_sf_unkonwns <- signs_sf_unkonwns |>
  left_join(acronyms, by = c("Sign_Acronym" = "Acronym"))
signs_sf_unkonwns <- signs_sf_unkonwns |>
  rename(`Sign Meaning` = Meaning)