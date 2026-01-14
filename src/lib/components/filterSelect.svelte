<script lang="ts">
  let { actors = $bindable(), availableGroups } = $props();
  let open = $state(false);

  function toggleActor(group: string) {
    if (actors.includes(group)) {
      actors = actors.filter(a => a !== group);
    } else {
      actors = [...actors, group];
    }
  }
</script>

<div class="dropdown">
  <button class="dropdown-button" onclick={() => (open = !open)}>
    Actor Groups ▾
  </button>

  {#if open}
    <div class="dropdown-menu">
      <fieldset>
        <legend>Select groups</legend>

        {#each availableGroups as group}
          <label class="checkbox-item">
            <input
              type="checkbox"
              value={group}
              checked={actors.includes(group)}
              onchange={() => toggleActor(group)}
            />
            {group}
          </label>
        {/each}

      </fieldset>
    </div>
  {/if}
</div>

<style>

  :root {
  --dropdown-bg: white;
  --dropdown-border: #ddd;
  --dropdown-shadow: 0 4px 12px rgba(0,0,0,0.15);
  --dropdown-radius: 8px;
  --dropdown-padding: 0.5rem;
  
  --button-bg: white;
  --button-border: #ccc;
  --button-shadow: 0 2px 4px rgba(0,0,0,0.1);
  --button-radius: 6px;
  --button-hover-bg: #f7f7f7;
  
  --font-family: 'Roboto Condensed', sans-serif;
  --font-size-sm: 0.85rem;
  --font-size-md: 0.9rem;
  --font-weight-normal: 400;
  --font-weight-bold: 500;
  
  --item-hover-bg: #fdae2a;
  --item-padding: 0.4rem 0.6rem;
  --item-radius: 6px;
  --item-gap: 0.25rem;
  
  --z-index-dropdown: 200;
}
  .dropdown {
    position: relative;
    display: inline-block;
    z-index: 50;
  }

  .dropdown-button {
    padding: 0.5rem 0.75rem;
    font-family: 'Roboto Condensed', sans-serif;
    font-weight: 400;
    background: white;
    border: 1px solid #ccc;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .dropdown-button:hover {
    background: #f7f7f7;
  }

  .dropdown-menu {
    position: absolute;
    top: 105%;
    left: 0;
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    padding: 0.5rem;
    z-index: 200;
    min-width: 200px;
  }

  fieldset {
    border: none;
    margin: 0;
    padding: 0;
  }

  legend {
    font-weight: bold;
    margin-bottom: 0.5rem;
    font-size: 0.9rem;
  }

  .checkbox-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin: 0.25rem 0;
  }
</style>
