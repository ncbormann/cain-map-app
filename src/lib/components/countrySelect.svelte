<script lang="ts">
  let { country = $bindable(), uniqueCountries,} = $props();
  let open = $state(false);

  function selectCountry(c: string) {
    country = c;
    open = false;
  }

</script>

<div class="dropdown">
  <button class="dropdown-button" onclick={() => (open = !open)}>
    {country ?? 'Country'} ▾
  </button>

  {#if open}
    <div class="dropdown-menu">
      <div class="menu-list">
        {#each uniqueCountries as c}
          <button
            class="menu-item"
            onclick={() => selectCountry(c)}
          >
            {c}
          </button>
        {/each}
      </div>

    </div>
  {/if}
</div>


<style>
.dropdown-menu {
  position: absolute;
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