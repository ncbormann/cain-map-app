<script lang="ts">
  let { country = $bindable(), countryOpen = $bindable(), filterOpen = $bindable(), showSuggestions = $bindable(), uniqueCountries} = $props();
  

  function selectCountry(c: string) {
    country = c;
    countryOpen = false;
  }

</script>

<div class="dropdown">
  <button class="dropdown-button" onclick={() => {
    countryOpen = !countryOpen;
    filterOpen = false;
    console.log(filterOpen)
    console.log(countryOpen)
    console.log(showSuggestions)
  }}>
    <span class="button-label">{country ?? 'Country'}</span>
    <span class="button-arrow">▾</span>
  </button>



  {#if countryOpen}
    <div class="dropdown-menu">
      <fieldset class="menu-list">
        {#each uniqueCountries as c}
          <button
            class="menu-item"
            onclick={() => selectCountry(c)}
          >
            {c}
          </button>
        {/each}
      </fieldset>
    </div>
  {/if}
</div>



<style>

.dropdown {
    position: relative;
    width:100%;
  }

.dropdown-menu {
  position: absolute;
  width: 100%;
  top: 105%;         
  left: 0;

  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  padding: 0.5rem;

  min-width: 200px;
  z-index: 200;
}

.menu-list {
  display: block;
  border: none;
  padding: 0;
  margin: 0;
}

  .dropdown-button {
    font-family: 'Roboto Condensed', sans-serif;
    font-weight: 400;
    display: inline-flex;          /* flex layout inside button */
    align-items: center;           /* vertically center */
    justify-content: space-between;/* text left, arrow right */
    padding: 0.5rem 0.75rem;
    width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    background: white;
    border: 1px solid #ccc;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .button-label {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-shrink: 1;                /* text can shrink */
  }

  .button-arrow {
    flex-shrink: 0;                /* arrow never shrinks or wraps */
    margin-left: 0.25rem;
  }

  .menu-list {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .menu-item {
    padding: 0.4rem 0.6rem;     
    text-align: left;
    background: transparent;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.85rem;
    transition: background-color 0.15s ease;
  }

  .menu-item:hover {
    background-color: #fdae2a;
  }




</style>