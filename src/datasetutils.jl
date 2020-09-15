
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
