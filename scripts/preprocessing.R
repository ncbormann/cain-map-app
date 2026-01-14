pacman::p_load(tidyverse, geojsonsf, stringr, lubridate, sf)
setwd(dirname(getwd())) 


europe <- read_csv("../src/lib/data/server_clean_241007.csv") %>%
  mutate(date_str = paste0(day_start,str_extract(month, "[a-zA-Z]+"),year),
         date = dmy(date_str)) 

# when I run this, 1504 fail to parse - probably because I'm pulling from two different sets of date columns.


nrow(europe %>% filter(is.na(date_start)))
nrow(europe %>% filter(is.na(date_str)))
nrow(europe %>% filter(is.na(month)))
date_test <- europe %>% filter(is.na(month))

actors_clean <- read_csv("../src/lib/data/all_actors_simpliefied_website_2521204.csv")


radius <- 0.0005

all_events_filtered <- europe %>%
  left_join(actors_clean, by = c("actor_a" = "actor", "actor_a_group" = "actor_group", "country_coded" = "country")) %>%
  rename(actor_group_a_reduced = actor_group_simplified) %>%
  left_join(actors_clean, by = c("actor_b" = "actor", "actor_b_group" = "actor_group", "country_coded" = "country")) %>%
  rename(actor_group_b_reduced = actor_group_simplified) %>%
  filter(!is.na(town_ln),
         !is.na(town_lat),
         !is.na(date)) %>%
  select(date, country_coded, town_ln, town_lat, actor_a, actor_b, actor_group_a_reduced, actor_group_b_reduced, deaths) %>%
  group_by(town_lat, town_ln) %>%
  mutate(
    n_points = n(),
    angle = (row_number() - 1) * (2 * pi / n_points),
    lat_new = if_else(n_points > 1, town_lat + radius * cos(angle), town_lat),
    lon_new = if_else(n_points > 1, town_ln + radius * sin(angle), town_ln),
  ) %>%
  ungroup() %>%
  mutate(index = row_number()) %>%
  select(-angle, -n_points)

nrow(europe)
nrow(all_events_filtered)


# country_bounds <- all_events_filtered %>%
#   group_by(country_coded) %>%
#   summarise(
#     min_lon = min(lon_new),
#     max_lon = max(lon_new),
#     min_lat = min(lat_new),
#     max_lat = max(lat_new),
#     center_lon = (min_lon + max_lon) / 2,
#     center_lat = (min_lat + max_lat) / 2
#   ) %>%
#   ungroup()

country_bounds <- all_events_filtered %>%
  group_by(country_coded) %>%
  reframe(
    # Sort longitudes, remove min/max, take new min/max
    sorted_lons = sort(lon_new),
    min_lon = ifelse(length(sorted_lons) > 2, sorted_lons[2], sorted_lons[1]),
    max_lon = ifelse(length(sorted_lons) > 2, 
                     sorted_lons[length(sorted_lons) - 1], 
                     sorted_lons[length(sorted_lons)]),
    
    # Sort latitudes, remove min/max, take new min/max
    sorted_lats = sort(lat_new),
    min_lat = ifelse(length(sorted_lats) > 2, sorted_lats[2], sorted_lats[1]),
    max_lat = ifelse(length(sorted_lats) > 2,
                     sorted_lats[length(sorted_lats) - 1],
                     sorted_lats[length(sorted_lats)]),
    
    # Calculate centers using the new bounds
    center_lon = (min_lon + max_lon) / 2,
    center_lat = (min_lat + max_lat) / 2
  ) %>%
  ungroup() %>%
  # Remove the temporary sorted columns
  select(-sorted_lons, -sorted_lats)

# Save as JSON
jsonlite::write_json(country_bounds, "../src/lib/data/country_bounds.json", pretty = TRUE)


europe_geojson <- df_geojson(df = all_events_filtered, lon = "lon_new" , lat = "lat_new")
country_bounds_json 

# Set working directory to file location to write directly to app data 
write_file(europe_geojson, "../src/lib/data/all_events_no_nulls.json")


europe_1925_countries <- c(
  "United Kingdom",
  "Ireland",
  "Netherlands",
  "Belgium",
  "Luxembourg",
  "France",
  "Switzerland",
  "Spain",
  "Portugal",
  "Germany (Prussia)",
  "Poland",
  "Danzig",
  "Austria",
  "Hungary",
  "Czechoslovakia",
  "Italy/Sardinia",
  "Albania",
  "Serbia",
  "Montenegro",
  "Yugoslavia",
  "Greece",
  "Bulgaria",
  "Rumania",
  # "Russia (Soviet Union)",
  "Estonia",
  "Latvia",
  "Lithuania",
  "Finland",
  "Sweden",
  "Norway",
  "Denmark",
  "Malta",
  "Cyprus",
  "Iceland"
)

country_borders <- read_csv("../src/lib/data/CShapes-2.0.csv") %>%
  mutate(name = cntry_name) %>%
  filter(name %in% europe_1925_countries)


  
  
  # mutate(name = case_when(cntry_name == "Germany (Prussia)" ~ "Germany",
  #                         cntry_name == "Italy/Sardinia" ~ "Italy",
  #                         TRUE ~ cntry_name))

countries <- unique(all_events_filtered$country_coded)

latest_borders <- country_borders %>%
  filter(gwsyear < 1926) %>%
  group_by(name) %>%
  reframe(max = max(gwsyear))

nineteentwentyfive <- country_borders %>%
  inner_join(latest_borders) %>%
  filter(gwsyear == max) %>%
  mutate(
    the_geom = st_as_sfc(the_geom),  # Convert MULTIPOLYGON WKT to geometry
    cap_geom = st_as_sfc(cap_geom)   # Convert POINT WKT to geometry
  ) %>%
  st_set_geometry("the_geom")  # Set the_geom as the main geometry column

plot(nineteentwentyfive$the_geom)

st_write(nineteentwentyfive, "../src/lib/data/all_borders_1925.geojson", driver = "GeoJSON")


