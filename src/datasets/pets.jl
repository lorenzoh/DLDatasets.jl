
module PetsData

using DataDeps
using ..DLDatasets
using FileIO: load
abstract type Pets end


# const
FOLDERTOLABEL = Dict(

)

# const
LABELS = [

]

# const
LABELTOCLASS = Dict(label => i for (i, label) in enumerate(LABELS))


function loadpets(folder::String, splits)
    dataset = FileDataset(folder, (loadfile, file -> FOLDERTOLABEL[file.parent.name]), filterfn = isimagefile)
    return splitdata(dataset, splits) do file
        file.parent.parent.name
    end
end

function loadpets(folder::String, splits)
    dataset = FileDataset(folder, (loadfile, file -> file.parent.name), filterfn = isimagefile)
    return splitdata(dataset, splits) do file
        file.parent.parent.name
    end
end

# adding to registry

DLDatasets.metadata(::Type{Pets}) = (
    obstypes = ("image", "category"),
    splits = ("train", "val"),
    labels = LABELS,
    labeltoclass = LABELTOCLASS,
)

function __init__()
    register(DataDep(
        "pets",
        """
        """,
        "https://s3.amazonaws.com/fast-ai-imageclas/oxford-iiit-pet.tgz",
        "3f1b76957366427dd5c12e3d48488be28dabd99a403bdb2b5100a83b9fd162d4";
        post_fetch_method = unpack,
    ))


    register!(
        DATASET_REGISTRY,
        Pets,
        "",
        (splits) -> loadpets(
            joinpath(datadep"pets", "oxford-iiit-pet", "images")
            , splits)
    )

end

export Pets


end
