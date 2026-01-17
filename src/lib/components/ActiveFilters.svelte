<script lang="ts">
    let {actors = $bindable(),
        subActors = $bindable(),
        dates = $bindable(),
        country = $bindable(),
        countryTimelineOnly = $bindable()} = $props() 


    function removeActor(a) {
        actors = actors.filter(x => x !== a);
    }

    function removeSubActor(obj) {
        subActors = subActors.filter(
            x => !(x.name === obj.name && x.country === obj.country)
        );
    }

    function removeCountry() {
    country = null;
    countryTimelineOnly = null;
    }

    const monthYear = new Intl.DateTimeFormat('en', {
        month: 'short',
        year: 'numeric'
    });


</script>

{#if actors.length || subActors.length || dates.length || country}
    <div class="filters">

        <!-- Country -->
        {#if country}
            <span class="chip" style="background-color: #fdae2a;">
                {country}
                <button onclick={removeCountry}>✕</button>
            </span>
        {/if}

        <!-- Actor groups from dropdown-->
        {#each actors as a}
            <span class="chip">
                {a}
                <button onclick={() => removeActor(a)}>✕</button>
            </span>
        {/each}

        <!-- Subactors from Search -->
        {#each subActors as sa}
            <span class="chip">
                {sa.name} ({sa.country})
                <button onclick={() => removeSubActor(sa)}>✕</button>
            </span>
        {/each}

        <!-- Dates from timeline-->
        {#if dates.length === 2}
            <span class="chip">
                {monthYear.format(dates[0])} – {monthYear.format(dates[1])}
                <button onclick={() => dates = []}>✕</button>
            </span>
        {/if}


    </div>
{/if}



<style>
    

    .filters {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;

        padding: 0.5rem;
        border-radius: 10px;
    }

    .chip {
        background: #eee;
        padding: 0.35rem 0.6rem;
        border-radius: 14px;
        display: flex;
        align-items: left;
        gap: 0.4rem;
        font-size: 0.85rem;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }

    .chip button {
        border: none;
        background: none;
        cursor: pointer;
        font-size: 0.9rem;
    }




</style>
