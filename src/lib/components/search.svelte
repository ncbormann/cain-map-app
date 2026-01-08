<script lang="ts">
    let {subActors = $bindable(), //this is the object we use for the filtering
        uniqueSubActorsTest,
        uniqueSubActors} = $props() // this is the reference list
        let searchTerm = $state('');
        let showSuggestions = $state(false);
        let selectedIndex = $state(-1);

        console.log(uniqueSubActors)



        const listMatches = $derived(
            uniqueSubActors
        .filter(a =>
            a.name.toLowerCase().includes(searchTerm.toLowerCase())
        )
        .sort((a, b) =>
            a.name.toLowerCase().indexOf(searchTerm.toLowerCase()) -
            b.name.toLowerCase().indexOf(searchTerm.toLowerCase())
        )
);


        function selectSuggestion(suggestion) {
            searchTerm = suggestion.name;
            showSuggestions = false;

            // Prevent duplicates
            if (!subActors.some(sa => sa.name === suggestion.name && sa.country === suggestion.country)) {
                        subActors = [
                            ...subActors,
                            { name: suggestion.name, country: suggestion.country }
                        ];
                    }

            console.log(subActors);
            searchTerm = ""
        }


       function splitForHighlight(text: string, query: string) {
            if (!query) return [{ text, match: false }];

            const escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(`(${escaped})`, 'ig');

            return text.split(regex).map(part => ({
                text: part,
                match: regex.test(part)
            }));
        }


        function handleKeyDown(event: KeyboardEvent) {

            if (event.key === "ArrowDown") {
                event.preventDefault();
                if (selectedIndex < listMatches.length - 1) selectedIndex += 1;
                return;
            }

            if (event.key === "ArrowUp") {
                event.preventDefault();
                if (selectedIndex > 0) selectedIndex -= 1;
                return;
            }

            if (event.key === "Enter" && selectedIndex >= 0) {
                event.preventDefault();
                selectSuggestion(listMatches[selectedIndex]);
                return;
            }

        }


</script>

<div class="relative z-10 m-2">
  <input
    type="text"
    placeholder="Search actor..."
    bind:value={searchTerm}
    onfocus={() => (showSuggestions = true)}
    onblur={() => setTimeout(() => (showSuggestions = false), 150)} 
    class="w-full p-2 rounded border shadow bg-white"
    onkeydown={handleKeyDown}
  />


  {#if showSuggestions}
    <ul id="suggestion-list">
      {#each listMatches as x, index}
        <!-- <li 
            class:selected={index === selectedIndex}
            onclick={() => selectSuggestion(x)}>
                {#each splitForHighlight(x, searchTerm) as part}
                    {#if part.match}
                        <span class="match">{part.text}</span>
                    {:else}
                        {part.text}
                    {/if}
                {/each}
            </li> -->
            <li 
                class={`flex justify-between items-center ${index === selectedIndex ? 'selected' : ''}`}
                onclick={() => selectSuggestion(x)}
            >
                <span>
                    {#each splitForHighlight(x.name, searchTerm) as part}
                        {#if part.match}
                            <span class="match">{part.text}</span>
                        {:else}
                            {part.text}
                        {/if}
                    {/each}
                </span>

                <span class="country">{x.country}</span>
            </li>

        {/each}

    </ul>
  {/if}
</div>

<style>
    #suggestion-list {
        list-style: none;      
        margin: 0;
        padding: 0;

        position: absolute;
        top: 100%;
        left: 0;
        right: 0;

        background: white;
        border: 1px solid #ddd;
        border-radius: 8px;

        box-shadow: 0px 4px 12px rgba(0,0,0,0.15);

        max-height: 200px;
        overflow-y: auto;

        z-index: 100;
}

        #suggestion-list li {
            padding: 0.625rem 0.75rem;
            cursor: pointer;
            font-size: 0.9rem;
            border-bottom: 1px solid #f0f0f0;
            display: flex;                 /* ensure text splits left + right */
            justify-content: space-between;
            align-items: center;
        }

        .country {
            font-size: 0.8rem;
            color: #9ca3af; /* tailwind gray-400 */
            margin-left: 1rem;
            white-space: nowrap;
        }

        #suggestion-list li:last-child {
        border-bottom: none;
        }

        #suggestion-list li:hover {
        background-color: #f5f5f5;
        }

        #suggestion-list li.selected { 
            background-color: #f5f5f5; }

        .match {
        border-bottom: 2px solid rgba(0,0,0,0.5);
        }


</style>


