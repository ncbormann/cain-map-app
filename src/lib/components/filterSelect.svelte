<script lang="ts">
  let { actors = $bindable(), uniqueActors } = $props();
  let open = $state(false);
</script>

<div class="dropdown">
  <button class="dropdown-button" onclick={() => (open = !open)}>
    Actor Groups ▾
  </button>

  {#if open}
    <div class="dropdown-menu">
      <fieldset>
        <legend>Select groups</legend>
        {#each uniqueActors as actorName}
          <label class="checkbox-item">
            <input
              type="checkbox"
              value={actorName}
              bind:group={actors}
              onchange={() => open = false}
            />
            {actorName}
          </label>
        {/each}
      </fieldset>
    </div>
  {/if}
</div>



<style>
  .dropdown {
    position: relative;
    display: inline-block;
    z-index: 50;
  }

  .dropdown-button {
    padding: 0.5rem 0.75rem;
    font-family:'Roboto Condensed', sans-serif;;
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