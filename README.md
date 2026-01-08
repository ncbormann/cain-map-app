This is a svelte app using svelte-maplibre and presenting research data from the CAIN project.

## Prerequisites

- [Node.js LTS](https://nodejs.org/) installed

## Setup

Clone the repository and install dependencies:

git clone <repo-url>
cd <repo-folder>
npm install

The data to populate the map is not included in this repo; to run the app with the data, save the raw data file (csv) AND the lookup table ("all_actors_simpliefied_website_2521204.csv") into the scripts file, then run the preprocessing script in R which will generate the json necessary to run the app.

## Run development server

npm run dev

## Run production version

npm run build
npm run preview