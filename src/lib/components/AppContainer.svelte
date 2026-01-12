<script>
    import MapCircles from '$lib/components/map/Maplibre_circles.svelte' 
    import geoEurope from '$lib/data/all_events_no_nulls?raw'
    import BarChart from '$lib/components/barChart.svelte' 
    import ActorSelector from '$lib/components/filterSelect.svelte' 
    import CountrySelector from '$lib/components/countrySelect.svelte' 
    import ActiveFilters from '$lib/components/ActiveFilters.svelte' 
    import Search from '$lib/components/search.svelte' 
    const europeGeoJson = JSON.parse(geoEurope)
    let mapZoom = $state(3)
    let toggle = $state(true)
    let actors = $state([])
    let subActors = $state([]) 
    let dates = $state([])
    let country = $state(null)
    let countryTimelineOnly = $state(false);


    const uniqueCountries= [...new Set(
        europeGeoJson.features.map(f => f.properties.country_coded)
    )];



    const uniqueActors = [
    ...new Map(
        europeGeoJson.features.flatMap(f => [
            { group: f.properties.actor_group_a_reduced, country: f.properties.country_coded },
            { group: f.properties.actor_group_b_reduced, country: f.properties.country_coded }
        ])
        .filter(x => x.group && x.country)                  // remove empty entries
        .map(x => [`${x.group}::${x.country}`, x])         // map for uniqueness
    ).values()
    ];


    let availableGroups = $derived.by(() => {
        return [
            ...new Set(
                uniqueActors
                    .filter(a => !country || a.country === country) 
                    .map(a => a.group)
            )
        ];
    });


    const uniqueSubActors = [
        ...new Map(
            europeGeoJson.features.flatMap(f => [
                { name: f.properties.actor_a, country: f.properties.country_coded, group: f.properties.actor_group_a_reduced },
                { name: f.properties.actor_b, country: f.properties.country_coded, group: f.properties.actor_group_b_reduced },
            ])
            .filter(x => x.name && x.country && x.group)
            .map(x => [`${x.name}::${x.country}`, x])
        ).values()
    ];


    const availableSubActors = $derived.by(() => {
        return uniqueSubActors.filter(sa => {
            const countryOk = !country || sa.country === country;
            const groupOk   = actors.length === 0 || actors.includes(sa.group);
            return countryOk && groupOk;
        });
    });


    function filterFeatures() {
    return europeGeoJson.features.filter(f => {

        // 5) COUNTRY FILTER
        const countryMatch =
            country
        ? f.properties.country_coded === country
        : true;


        // 1) SPECIFIC ACTOR–COUNTRY FILTER (takes priority)
        const specificActorMatch =
            subActors.length > 0 &&
            subActors.some(sa =>
                (f.properties.actor_a === sa.name && f.properties.country_coded === sa.country) ||
                (f.properties.actor_b === sa.name && f.properties.country_coded === sa.country)
            );

        // 2) REDUCED GROUP FILTER (used only if no subActors selected)
        const reducedActorMatch =
            subActors.length === 0 && actors.length > 0 &&
            (actors.includes(f.properties.actor_group_a_reduced) ||
             actors.includes(f.properties.actor_group_b_reduced));

        // 3) IF no actor filters active → allow everything
        const actorMatch =
            subActors.length > 0 ? specificActorMatch :     // ✔ priority
            actors.length > 0    ? reducedActorMatch  :     // ✔ fallback
                                  true;                     // ✔ no filter active

        // 4) DATE FILTER remains unchanged
        const dateMatch =
            dates.length === 2
                ? new Date(f.properties.date) >= dates[0] &&
                  new Date(f.properties.date) <= dates[1]
                : true;

        return actorMatch && dateMatch && countryMatch;
    });
}

let filteredData = $derived({ ...europeGeoJson, features: filterFeatures() });

</script>


<div class="container">
    <div class="toolbar-wrapper">
        <div id="toolbar">
            <CountrySelector uniqueCountries={uniqueCountries} bind:country={country}/>
            <ActorSelector availableGroups={availableGroups} bind:actors={actors}/>
            <Search uniqueSubActors={availableSubActors}
                    bind:subActors={subActors} />
        </div>

        {#if country}
            <label class="country-toggle">
                <input type="checkbox" 
                bind:checked={countryTimelineOnly}
                onchange={() => { dates = []; }} />
                Show timeline for {country} only
            </label>
        {/if}


    </div>
    <ActiveFilters  bind:actors={actors} 
    bind:subActors={subActors} 
    bind:dates={dates}
    bind:country={country}
    uniqueCountries
    bind:countryTimelineOnly={countryTimelineOnly}/>
    
    <MapCircles bind:zoom={mapZoom} 
    filteredData={filteredData}/> 
</div>


<div id="timeline">
    <BarChart filteredData={filteredData} bind:dates = {dates} countryTimelineOnly={countryTimelineOnly} country={country}/>

</div>


  <style>
    :global(html, body) {
        height: 100%;
        margin: 0;
        padding: 0;
        font-family: 'Roboto Condensed', sans-serif;
    }

    .container {
        position: relative;
        width: 100%;
        height: 100%;
        overflow: hidden; 
    }

    /* map fills the container  */
    .container :global(.maplibre-map) {
        position: absolute !important;
        top: 0;
        left: 0;
        width: 100% !important;
        height: 100% !important;
        /* overflow: hidden;  */
    }

    /* ------------------------------ */
    /*           TOOLBAR              */
    /* ------------------------------ */

    .toolbar-wrapper {
        position: relative;   /* makes absolute children relative to this */
        display: flex;
        flex-direction: column;
        align-items: flex-start; /* stack toolbar and filters */
        gap: 0.5rem;
    }

    #toolbar {
        position: absolute;
        top: 1rem;               
        left: 50%;
        transform: translateX(-50%);
        z-index: 30;

        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 1rem;

        width: calc(100% - 2rem);  
        max-width: 420px;

        background: white;
        border-radius: 10px;
        padding: 0.75rem;
        box-shadow: 0 3px 12px rgba(0,0,0,0.18);
    }


    #timeline {
        position: absolute;
        bottom: 0.75rem;    /* slight breathing room */
        left: 50%;
        transform: translateX(-50%);
        z-index: 25;

        width: 90%;
        max-width: 1000px; 

        background: white;
        border-radius: 10px 10px 10px 10px; /* nice top-curve */
        box-shadow: 0 -3px 12px rgba(0,0,0,0.2);

        padding: 0.5rem 1rem;
    }

    .country-toggle {
    display: flex;
    align-items: center;
    font-size: 0.85rem;
    gap: 0.4rem;
    margin-left: 1rem;
    z-index: 50;
    }
    .country-toggle input[type="checkbox"] {
        cursor: pointer;
    }
</style>