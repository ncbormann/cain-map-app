<script lang="ts">
  import { MapLibre, CircleLayer, GeoJSON, Popup} from 'svelte-maplibre';
  import type { LngLatBoundsLike } from 'maplibre-gl';
  let {zoom = $bindable(), filteredData, country = $bindable(), boundingBoxes} = $props()


  // let bounds: LngLatBoundsLike = $state([-10.0, 24.5, 31.5, 61.5]);

  const europeBBox: LngLatBoundsLike = [-10.0, 24.5, 31.5, 61.5];

  // bounds is reactive and will update automatically based on country
 let bounds: LngLatBoundsLike = $derived.by(() => {
  if (!country) return europeBBox; // default to Europe

  if (!boundingBoxes) return europeBBox; // safeguard

  const b = boundingBoxes.find(b => b.country_coded === country);
  return b ? [b.min_lon, b.min_lat, b.max_lon, b.max_lat] : europeBBox;
});

  
</script>

<!-- center={[14,52]} -->

<MapLibre  
  style = "https://api.maptiler.com/maps/019ba32c-43d2-74ac-bdba-1768cc85c5c2/style.json?key=GDx9s6OzDP05pKKgG4wT"
  bind:zoom={zoom}
  bind:bounds={bounds}
>
  <GeoJSON 
      id="europeMap" 
      data={filteredData}
      cluster = {{
          radius: 50,
          maxZoom: 12,
          properties: {
            event_count: ['+', ['get', 'point_count']]
          }
      }}
  >
    
  <CircleLayer
      id="clusters"
      source="europeMap"
      hoverCursor="pointer"
      applyToClusters
      manageHoverState
      paint={{
        'circle-radius': [
            'interpolate',
            ['linear'],
            ['zoom'],
            5, [
              'interpolate', ['linear'], ['get', 'point_count'],
              1, 7,
              500, 35
            ],
            10, [
              'interpolate', ['linear'], ['get', 'point_count'],
              1, 10,
              500, 50
            ]
          ],
        'circle-color': [
            'interpolate',
            ['linear'],
            ['get', 'point_count'],
            2, '#fdae2a',
            20, '#f6973d',
            40, '#e9844b',
            80, '#d87355',
            200, '#d87355',
            420, '#d87355'
          ]
        }}
        filter={['has', 'point_count']}  
  />


<CircleLayer
  id="unclustered-points"
  source="europeMap"
  hoverCursor="pointer"
  paint={{
    'circle-radius': 5,
    'circle-color': '#fec604',
    'circle-stroke-width' : 1.5
  }}
  filter={['!', ['has', 'point_count']]}   
>
  
  
    <Popup openOn="click">
      {#snippet children({ data })}
        {#if data?.properties}

          <div class="map-popup">

            <div class="meta">
              <span>{data.properties.date}</span>
              <span>{data.properties.country}</span>
            </div>


            <div class="actors">
              <p>Event involving</p>
              <div class="actor">{data.properties.actor_a}</div>
              <div class="actor">{data.properties.actor_b}</div>
            </div>


            {#if data.properties.deaths}
              <div class="deaths">Deaths: {data.properties.deaths}</div>
            {/if}
            <!-- Button removed pending external sourcing of primary materials -->
            <!-- <button 
              class="fulltext-btn"
              onclick={() => openFullText(data.properties.index, data.properties.date)}
            >
              Full report text
            </button> -->
          </div> 

        {:else}
          <div class="map-popup">No data available</div>
        {/if}
      {/snippet}
    </Popup>

  </CircleLayer>
  </GeoJSON>
</MapLibre>


<style>


  /* Outer popup wrapper */
  .map-popup {
    font-family: var(--e-global-typography-text-font-family, "Roboto condensed"), sans-serif;
    padding: 10px 14px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    max-width: 230px;
  }

  /* Date + Country small metadata */
  .meta {
    display: flex;
    justify-content: space-between;
    font-size: 0.75rem;
    color: #555;
    opacity: 0.8;
  }

  /* Main actor names */
  .actors {
    font-size: 0.75rem;
    display: flex;
    flex-direction: column;
    gap: 0px;
  }

  .actor {
    font-size: 0.85rem;
    font-weight: 500;
    color: #383C42;  
  }

  /* Death count */
  .deaths {
    font-size: 0.85rem;
    color: #D87355; 
    margin-top: 4px;
    font-weight: 500;
  }

  /* Button for modal */
  /* .fulltext-btn {
    margin-top: 6px;
    padding: 6px 10px;
    font-size: 0.8rem;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    background: #FEC604;       
    color: #383C42;
    font-weight: 600;
    transition: background 0.2s;
  } */

  /* .fulltext-btn:hover {
    background: #e0b000;
  } */

  /* .modal-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 2000;
  } */

  /* Modal box */
  /* .modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    width: min(600px, 90%);
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
    z-index: 2001;
  } */

  /* Close button */
  /* .close-btn {
    position: absolute;
    top: 8px;
    right: 12px;
    background: none;
    border: none;
    font-size: 1.6rem;
    cursor: pointer;
    line-height: 1;
  } */

  /* Text inside modal */
  /* .modal-content {
    max-height: 65vh;
    overflow-y: auto;
    padding-right: 8px;
  }

  .modal-content h3 {
    margin-top: 0;
    margin-bottom: 12px;
    font-size: 1.2rem;
  }

  .modal-content p {
    white-space: pre-wrap;
    line-height: 1.45;
  } */

</style>