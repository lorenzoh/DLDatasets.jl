
struct Entry{T}
    tag
    loadfn
end

@with_kw struct Registry
    datasets::Dict{Type, Dict{Any, Entry}} = Dict{Type, Dict{Any, Entry}}()
    localdatasets::Dict{Type, Dict{Any, Entry}} = Dict{Type, Dict{Any, Entry}}()
end

const DATASET_REGISTRY = Registry()

function register!(registry::Registry, DatasetType, tag, loadfn)
    if isnothing(get(registry.datasets, DatasetType, nothing))
        registry.datasets[DatasetType] = Dict{Any, Entry}()
    end
    registry.datasets[DatasetType][tag] = Entry{DatasetType}(tag, loadfn)
end

metadata(::T) where T = (;)


"""
    loaddataset([registry], Dataset, tag, [splits])
"""
function loaddataset(registry::Registry, DatasetType::Type, tag = nothing; split = nothing, kwargs...)
    if isnothing(tag)
        tag = first(keys(registry.datasets[DatasetType]))
    end

    ds = registry.datasets[DatasetType][tag].loadfn(split; kwargs...)
end


function datasets(registry = DATASET_REGISTRY)
    for (D, entries) in registry.datasets
        println(D => (tags = collect(keys(entries)), metadata(D)...))
    end
end


loaddataset(type::Type, tag = nothing; split = nothing, kwargs...) =
    loaddataset(DATASET_REGISTRY, type, tag; split = split, kwargs...)
