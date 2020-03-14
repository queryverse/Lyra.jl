module Lyra

using Electron, DataValues

import IteratorInterfaceExtensions, TableTraits, IterableTables, JSON, VegaLite
using FilePaths

export LyraWindow, add!

app = nothing

mutable struct LyraWindow
    w::Window

    function LyraWindow()
        main_html_uri = abs(join(@__PATH__, p"../assets/lyra/index.html"))

        @info main_html_uri

        global app

        if app == nothing
            app = Application()
        end

        w = Window(app, main_html_uri, options = Dict("title" => "Lyra"))

        new(w)
    end
end

function add!(v::LyraWindow, name::Symbol, data)
    TableTraits.isiterabletable(data) === false && error("'data' is not a table.")

    it = IteratorInterfaceExtensions.getiterator(data)

    data_dict = Dict{String,Any}()

    data_dict["values"] = [Dict{Symbol,Any}(c[1] => isa(c[2], DataValue) ? (isna(c[2]) ? nothing : get(c[2])) : c[2] for c in zip(keys(r), values(r))) for r in it]

    x = [Dict{Symbol,Any}(c[1] => isa(c[2], DataValue) ? (isna(c[2]) ? nothing : get(c[2])) : c[2] for c in zip(keys(r), values(r))) for r in it]

    # data = JSON.json(data_dict)

    data = JSON.json(x)

    data_as_string = JSON.json(data)

    code = """
    global.addData('$name', $data_as_string)
    """

    run(v.w, code)

    return nothing
end

function Base.getindex(v::LyraWindow)
    code = "global.getVegaSpec()"

    content = run(v.w, code)

    return VegaLite.VGSpec(content)
end

function Base.close(v::LyraWindow)
    close(v.w)
end

end # module
