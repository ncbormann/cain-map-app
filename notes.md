To do:


1. scatter the grouped points in pre-processing, and mark them as such. Suggest colouring the points with specific location in formation sligthly differently 
2. Add deaths to popup
3. Add a search filter with autocomplete



Gotta start actually writing my pseudocode before I start
also make a diagram of the app structure

For the searchbar:

Goal

Filter your existing GeoJSON points by actor name, with autocomplete suggestions as the user types.

🧩 Recommended Architecture
1. Keep filtering logic inside Svelte

Your filteredData is already reactive. You just need a searchTerm and a derived filtered dataset:

$: filteredData = allData.features.filter(f => f.properties.actor_a.includes(searchTerm))

2. Add an autocomplete component

There are two good options here:

Option A: Use a lightweight Svelte autocomplete library

Use a simple, dependency-light package like svelte-autocomplete or @svelteuidev/completion
You provide a list of possible actor names (unique from your dataset), and it handles:

Suggestion dropdown

Keyboard navigation

Selecting a value

Example structure:
<Autocomplete
  items={actorList}
  bind:value={searchTerm}
  placeholder="Search actor..."
  on:change={updateFilter}
/>
