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
    <span class="button-label">Actor Groups</span>
    <span class="button-arrow">▾</span>
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

 
  .dropdown {
    position: relative;
    width: 100%;
  }

  .dropdown-button {
    display: inline-flex;          /* flex layout inside button */
    align-items: center;           /* vertically center */
    justify-content: space-between;/* text left, arrow right */
    padding: 0.5rem 0.75rem;
    width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    background: white;
    font-family: 'Roboto Condensed', sans-serif;
    font-weight: 400;
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
