<script>
    import * as d3 from 'd3'
    import { onMount } from 'svelte';
    import borders1925 from '$lib/data/borders_1925.geojson';


    let isMobile = $state(false);

    onMount(() => {
        const media = window.matchMedia('(max-width: 640px)');

        const update = () => {
        isMobile = media.matches;
        };

        update(); // set initial value
        media.addEventListener('change', update);

        return () => media.removeEventListener('change', update);
    });



    let {filteredData, 
        dates = $bindable(), 
        countryTimelineOnly = $bindable(), 
        country = $bindable()} = $props()

    let consistentData = filteredData



    let timelineFeatures = $derived.by(() => {
    // Toggle OFF → always show whole-Europe timeline
        if (!countryTimelineOnly || !country) {
            return consistentData.features;
        }

        // Toggle ON → country-only timeline
        return consistentData.features.filter(
            f => f.properties.country_coded === country
        );
    });


    let backgroundChart = $derived.by(() => {
        return Array.from(
            d3.rollup(
                timelineFeatures,
                v => v.length,
                d => +d3.timeMonth.floor(new Date(d.properties.date))
            ),
            ([timestamp, count]) => ({
                month: new Date(timestamp),
                count
            })
        ).sort((a, b) => a.month - b.month);
    });


    let chartData = $derived(
        Array.from(
            d3.rollup(
                filteredData.features,
                v => v.length,
                d => +d3.timeMonth.floor(new Date(d.properties.date)) 
            ), ([timestamp, count]) => ({
            month: new Date(timestamp), 
            count: count
        })).sort((a, b) => a.month - b.month) 
    );

    

    let width = 928;
    let height = $derived(isMobile ? 220 : 100);
    let marginTop = 20;
    let marginRight = 0;
    let marginBottom = $derived(isMobile ? 30 : 10);
    let marginLeft = 40;
    let brush;
    let brushLayer;
    let prevDomain = null;
    let selectedStart = $state(null);
    let selectedEnd = $state(null);
    let axisLayer;
    let hadDates = $state(false);
    let tooltipText = $state('');
    let tooltipX = $state(0);
    let tooltipY = $derived(isMobile ? marginTop + 36 : marginTop - 5);


    let innerHeight = $derived(height - marginTop - marginBottom);
    let innerWidth = width - marginLeft - marginRight;

    let bar_height = $derived(
        d3.max(backgroundChart, d => d.count) ?? 0
    );

    let xScale = $derived.by(() =>
        d3.scaleTime()
            .domain(
                d3.extent(
                    timelineFeatures,
                    d => new Date(d.properties.date)
                )
            )
            .range([0, innerWidth])
    );

    let yScale = $derived.by(() =>
        d3.scaleLinear()
            .domain([0, bar_height])
            .range([0, innerHeight])
    );


    let month_count = $derived.by(() => {
        const domain = xScale.domain();
        if (!domain[0] || !domain[1]) return 1;

        return d3.timeMonth.count(
            d3.timeMonth.floor(domain[0]),
            d3.timeMonth.ceil(domain[1])
        );
        });

    $effect(() => {
        if (!axisLayer) return;

        const xAxis = d3.axisBottom(xScale)
            .ticks(isMobile ? d3.timeYear.every(2) : d3.timeYear.every(1))   // yearly ticks, biannual on mobile
            .tickFormat(d3.timeFormat("%Y")); // only show year


        const g = d3.select(axisLayer);
        g.call(xAxis);
        g.selectAll("text")
    });

    $effect(() => {
    if (!brushLayer) return;

    brush = d3.brushX()
        .extent([
        [0, 0],
        [innerWidth, innerHeight]
        ])
        .on("end", (event) => {
        const selection = event.selection;
        if (!selection) {
            // Brush cleared
            selectedStart = null;
            selectedEnd = null;
            tooltipText = '';
            dates = [];
            return;
        }
        const [x0, x1] = selection;
        selectedStart = xScale.invert(x0);
        selectedEnd = xScale.invert(x1);
        dates = [selectedStart, selectedEnd]
        })
        .on("brush", (event) => {
            if (!event.selection) return;
            const [x0, x1] = event.selection;
            const start = xScale.invert(x0);
            const end = xScale.invert(x1);
            tooltipText = d3.timeFormat("%b %Y")(start) + " – " + d3.timeFormat("%b %Y")(end);
            tooltipX = (x0 + x1) / 2;
        })

    d3.select(brushLayer).call(brush);
    });

    $effect(() => {
        if (!brush || !brushLayer) return;

        const hasDates = dates.length === 2;


        if (hadDates && !hasDates) {
            d3.select(brushLayer).call(brush.move, null);
            tooltipText = '';
            selectedStart = null;
            selectedEnd = null;
        }

        hadDates = hasDates;
        });

    

</script>

<div id = "barplot">

    <!-- {#if country}
        <label class="country-toggle">
            <input type="checkbox" 
            bind:checked={countryTimelineOnly}
            onchange={() => { dates = []; }} />
            Show timeline for {country} only
        </label>
    {/if} -->

    {#if country}
    <label class="country-toggle">
        <span class="toggle-label left">Europe</span>
        <div class="toggle-switch" class:active={countryTimelineOnly}>
        <input 
            type="checkbox" 
            bind:checked={countryTimelineOnly}
            onchange={() => { dates = []; }}
        />
        <span class="slider"></span>
        </div>
        <span class="toggle-label right">{country}</span>
    </label>
    {/if}

    <svg id = "barplot-svg"
        {width}
        {height}
        viewBox={`0 0 ${width} ${height}`}
>
    <g fill = "grey">
        {#each backgroundChart as event}
            <rect
                x = {xScale(event.month) + (width/month_count * 0.5)/2}
                y = {innerHeight - yScale(event.count)}
                class = "background-bar"
                width = {width/month_count * 0.5}
                height = {yScale(event.count)} />
        {/each}
        </g>
                
    <g fill = "#fec604">
        {#each chartData as event}
            <rect
                x = {xScale(event.month) + (width/month_count * 0.5)/2}
                y = {innerHeight - yScale(event.count)}
                class="selectable-bar"
                width = {width/month_count * 0.5}
                height = {yScale(event.count)}/> 
        {/each} 
        </g>
             
            <g class="x-axis" bind:this={axisLayer} transform={`translate(0,${innerHeight})`}></g>
            <g class="brush-layer" bind:this={brushLayer}></g>
            <text class="brush-tooltip" x={tooltipX} y={tooltipY}>{tooltipText}</text>
    </svg>
</div>


<style>
    .selectable-bar:hover {
        opacity: 0.8
    }

    #barplot {
        background-color: white;
    }

    #barplot-svg {
        max-width: 100%; 
        height: auto;
    }

    .brush-tooltip {
        font-weight: bolder;
        font-weight: 400;
    }

    .x-axis {
        font-family: 'Roboto Condensed', sans-serif;
        font-weight: bold;
    }

    :global(.x-axis text) {
        font-size: 14px;
    }

    @media (max-width: 640px) {
        :global(.x-axis text) {
            font-size: 30px;
        }

        .brush-tooltip {
            font-size: 28px;
        }


        }


        
    .country-toggle {
        display: flex;
        align-items: center;
        font-size: 0.85rem;
        gap: 0.5rem;
        margin-left: 1rem;
        z-index: 50;
        font-family: 'Roboto Condensed', sans-serif;
        cursor: pointer;
        user-select: none;
    }
    
    .toggle-switch {
        position: relative;
        display: inline-block;
        width: 48px;
        height: 24px;
    }
    
    .toggle-switch input {
        opacity: 0;
        width: 0;
        height: 0;
        position: absolute;
    }
    
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .3s;
        border-radius: 24px;
    }
    
    .slider:before {
        position: absolute;
        content: "";
        height: 18px;
        width: 18px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .3s;
        border-radius: 50%;
    }
    
    .toggle-switch.active .slider {
        background-color: #fec604;
    }
    
    .toggle-switch.active .slider:before {
        transform: translateX(24px);
    }
    
    .toggle-label {
        font-weight: 400;
        color: #333;
    }
    
    .toggle-label.left {
        margin-right: 0.25rem;
    }
    
    .toggle-label.right {
        margin-left: 0.25rem;
    }

    
    

</style>
