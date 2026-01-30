# CAIN Map Visualization

This is a **SvelteKit app** using `svelte-maplibre` to present research data from the CAIN project.

---

## Prerequisites

- [Node.js LTS](https://nodejs.org/) installed  
- [R](https://www.r-project.org/) installed (for preprocessing the data)

---

## Setup

1. Clone the repository and install dependencies:

```
git clone <repo-url>
cd <repo-folder>
npm install
```


2. Prepare the data:

> The data to populate the map is **not included** in this repository.  
> To run the app:

- Place the raw CSV file **and** the lookup table (`all_actors_simplified_website_2521204.csv`) in the `scripts/` folder  
- Run the preprocessing script in R


This will generate the JSON files necessary for the app in `src/lib/data/`.

---

## Run the development server

```
npm run dev
``` 

> This will serve the development version of the app over the local network, so it can be inspected on a phone.

---

## Build and preview production version
```
npm run build
npm run preview
```


> This will build a production-ready version of the app and serve it locally for testing.

---

## Hosting the Static App on GitHub Pages

First, clone this entire repo to your own account so that you have an independent version on your own Github account. Then download the clone to work from -- that way when you deploy it'll be to your own account.

This repo (on my account) actually has the static app on its gh-pages branch. So you can just clone it, and then jump straight to 3. But if you want to make any changes to it, you'll need to be able to deploy from your local machine so it's worth cloning, downloading, and then deploying.


#### 1. First-Time Setup (Run once)

```bash
npm install -D @sveltejs/adapter-static 

git checkout -b gh-pages
git rm -rf .  # Remove everything (need empty branch to initialize)
git commit -am "Initialize gh-pages branch"
git push origin gh-pages
git checkout main 

``` 

Once you're back on main, having pushed the gh-pages branch to github, you can then run the development server until you're ready to deploy the static app.

#### 2. Deploying updates

To push the static version of the app to your own Github pages, first make sure any changes you've made are committed (I suggest always doing this in a local branch) then run:


``` 
npm run build:static
STATIC_BUILD=true npm run preview

``` 
from inside the 'build' folder. That will let you test the static version on the preview server.

Once that works, run:

``` 
npm run deploy

``` 
This will build the app again, and push the static version to the gh-pages branch on github.


### 3. Setting up the repo on Github

Go to the repository and follow Settings -> Pages.  
Under Source, select:  
Branch: gh-pages  
 Folder: / (root)  
Save


## Changing the basemap style

The basemap style at present is created in [MapTiler](https://www.maptiler.com/).

To make changes to it (for instance, to change the colours, or to add and remove map features like town names, streets, landmarks, roads etc) you can create an account on MapTiler, then select 'New map' -> 'Customise'. This will bring you to a screen with the basic map style you've chosen, and a menu on the left hand side which offers 'quick edits', 'layers', and 'settings'. Under layers you'll find the map features which you can show or hide. The only one that really ought to stay hidden at this time is 'country borders', because we are using our own country border file which is loaded separately.

Once you've styled the map, hit 'save' -> 'create and save' -> 'publish'.

Once it's published, return to the MapTiler home page, and you'll now have a section called 'My maps'. Select that, and scroll down to where it says "Use vector style". Copy that link, and in map/Maplibre_circles.svelte you'll find the place to paste it, inside the first <Maplibre> tag, on line 30. 


## Features still to add

1. Pdf download (in progress)
2. Timeline live-update on select
3. Map borders respond to date selection
