
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

splitdata(splitfn, dataset, splits::Nothing) = dataset


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


zipdata(datas...) = ZipData(datas)
struct ZipData
    datas::Tuple
end
LearnBase.nobs(data::ZipData) = minimum(nobs.(data.datas))
function LearnBase.getobs(data::ZipData, idx)
    Tuple(getobs(d, idx) for d in data.datas)
end
