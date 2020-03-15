# Lyra

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![codecov.io](http://codecov.io/github/queryverse/Lyra.jl/coverage.svg?branch=master)](http://codecov.io/github/queryverse/Lyra.jl?branch=master)

## Overview

This package provides Julia integration for the [Lyra](https://github.com/vega/lyra) Visualization Design Environment.

NOTE THAT THIS PACKAGE CURRENTLY USES A VERY EXPERIMENTAL AND UNSTABLE BUILD OF LYRA AND IS NOT READY FOR REAL USE.

## Getting Started

Lyra.jl is an interactive environment that enables custom visualization design without writing any code.

You can install the package at the Pkg REPL-mode with:

````julia
pkg> add https://github.com/queryverse/Lyra.jl
````

## Visualizing data

You create a new Lyra window by calling `LyraWindow`:

````julia
using Lyra

l = LyraWindow()
````

By itself this is not very useful, the next step is to load some data into Lyra. Lets assume your data is in a `DataFrame`:

````julia
using DataFrames, Lyra

data = DataFrame(a=rand(100), b=randn(100))

l = LyraWindow(data)
````

You can also use the pipe to load data into Lyra:

````julia
using DataFrames, Lyra

data = DataFrame(a=rand(100), b=randn(100))

l = data |> LyraWindow()
````

With a more interesting data source

```julia
using VegaDatasets, Lyra

l = dataset("cars") |> LyraWindow()
```

You can load any source that implements the [TableTraits.jl](https://github.com/queryverse/TableTraits.jl) interface into Lyra, i.e. not just `DataFrame`s. For example, you can load some data from a CSV file with [CSVFiles.jl](https://github.com/queryverse/CSVFiles.jl), filter them with [Query.jl](https://github.com/queryverse/Query.jl) and then visualize the result with Lyra:

```julia
using FileIO, CSVFiles, Query, Lyra

l = load("data.csv") |> @filter(_.age>30) |> LyraWindow()
```

In this example the data is streamed directly into Lyra and at no point is any `DataFrame` allocated.

The datasets we added so far were named with the default name `dataset`. You can also give the dataset your own name, by passing a `Pair` instead of the raw data to `LyraWindow`:

```julia
using VegaDatasets, Lyra

l = LyraWindow(:cars=>dataset("cars"))
```

You can also make multiple datasets available to the Lyra environment. In that case you need to give each a unique name. The following example passes both the `cars` and `movies` dataset to Lyra:

```julia
using VegaDatasets, Lyra

l = LyraWindow(:cars=>dataset("cars"), :movies=>dataset("movies"))
```

You can use the `add!` function to add additional datasets to an existing Lyra window:

```julia
using VegaDatasets, Lyra

l = LyraWindow()

add!(l, :movies=>dataset("movies"))
```

## Extracting plots

You can also access a plot that you have created in the Lyra UI from Julia, for example to save the plot to disc.

You can access the currently active plot in a given Lyra window `l` with the brackets syntax:

```julia
using VegaDatasets, Lyra, VegaLite

l = dataset("cars") |> LyraWindow()

plot1 = l[]
```

At this point `plot1` will hold a standard [VegaLite.jl](https://github.com/queryverse/VegaLite.jl) plot object. You can use the normal [VegaLite.jl](https://github.com/queryverse/VegaLite.jl) functions to display such a plot, or save it to disc:

```julia
display(plot1)

plot1 |> save("figure1.pdf")
```

A useful pattern here is to save the plot as a Vega JSON file to disc, without the data:

```julia
using VegaDatasets, Lyra, VegaLite

l = dataset("cars") |> LyraWindow()

# Now create the plot in the UI

l[] |> save("figure1.vega")
```

At a later point you can then load this plot specification again, but pipe new data into it [TODO Make sure this works]:

```julia
using VegaLite, VegaDatasets

dataset("cars") |> load("figure1.vega")
```
