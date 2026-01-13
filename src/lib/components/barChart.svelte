<script>
    import * as d3 from 'd3'
    let {filteredData, dates = $bindable(), countryTimelineOnly = $bindable(), country} = $props()
    let consistentData = filteredData

    // let backgroundChart = $derived(
    //     Array.from(
    //         d3.rollup(
    //         consistentData.features,
    //         v => v.length,
    //         d => +d3.timeMonth.floor(new Date(d.properties.date))
    //         ),
    //         ([timestamp, count]) => ({
    //         month: new Date(timestamp),
    //         count
    //         })
    //     ).sort((a, b) => a.month - b.month)
    //     );

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
    let height = 100;
    let marginTop = 20;
    let marginRight = 0;
    let marginBottom = 5;
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
    let tooltipY = $state(marginTop - 5); 

    const innerWidth = width - marginLeft - marginRight;
    const innerHeight = height - marginTop - marginBottom;

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
            .ticks(d3.timeYear.every(1))   // yearly ticks
            .tickFormat(d3.timeFormat("%Y")); // only show year


        const g = d3.select(axisLayer);
        g.call(xAxis);
        g.selectAll("text")
            .style("font-size", "10px");
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

</style>
