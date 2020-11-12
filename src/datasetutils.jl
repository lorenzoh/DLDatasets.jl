
# # Data container utilities
#
# - [`catdata`](#)
# - [`splitdata`](#)

function loadobs(fs::Tuple, obs)
    return Tuple(f(obs) for f in fs)
end
loadobs(f, obs) = f(obs)


function splitdata(splitfn, data, split)
    return filter(x -> splitfn(x) == split, data)
end

function splitdata(splitfn, dataset, splits::Tuple)
    return Tuple(splitdata(splitfn, dataset, split) for split in splits)
end

function splitdata(dataset, splits::Tuple)
    return Tuple(splitdata(dataset, split) for split in splits)
end

splitdata(splitfn, dataset, splits::Nothing) = dataset



struct MappedData
    f
    data
end

Base.show(io::IO, data::MappedData) = print(io, "mapdata($(data.f), $(data.data))")

LearnBase.nobs(data::MappedData) = nobs(data.data)
LearnBase.getobs(data::MappedData, idx::Int) = data.f(getobs(data.data, idx))
LearnBase.getobs(data::MappedData, idxs::AbstractVector) = data.f.(getobs(data.data, idxs))

"""
    mapdata(f, data)

Lazily maps function `f` over container `data`.
"""
const mapdata = MappedData


"""
    catdata(datas...)

Concatenates data containers in the order they are passed.
"""
catdata(datas...) = CatData(datas)

struct CatData
    datas::Tuple
end

LearnBase.nobs(data::CatData) = sum(nobs.(data.datas))
function LearnBase.getobs(data::CatData, idx)
    ns = nobs.(data.dates)
    for (i, n) in enumerate(ns)
        if idx <= n
            return getobs(data.datas[i], idx)
        else
            idx -= n
        end
    end
end
