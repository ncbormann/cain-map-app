# CAIN Map Visualization

This is a **SvelteKit app** using `svelte-maplibre` to present research data from the CAIN project.

---

## Prerequisites

- [Node.js LTS](https://nodejs.org/) installed  
- [R](https://www.r-project.org/) installed (for preprocessing the data)

---

## Setup

1. Clone the repository and install dependencies:

git clone <repo-url>
cd <repo-folder>
npm install


2. Prepare the data:

> The data to populate the map is **not included** in this repository.  
> To run the app:

- Place the raw CSV file **and** the lookup table (`all_actors_simplified_website_2521204.csv`) in the `scripts/` folder  
- Run the preprocessing script in R


This will generate the JSON files necessary for the app in `src/lib/data/`.

---

## Run the development server

npm run dev -- --open

---

## Build and preview production version

npm run build
npm run preview


> This will build a production-ready version of the app and serve it locally for testing.

---

