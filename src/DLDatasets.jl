module DLDatasets


using FileTrees
import FileIO: load
using LearnBase
using Parameters



function zipdata(datas...) end


# Dataset API
include("./filedataset.jl")
include("./datasetutils.jl")

# Dataset Registry
include("./registry.jl")

# Dataset implementations

include("datasets/imagenette.jl")
using .ImageNetteData
include("datasets/imagewoof.jl")
using .ImageWoofData


export
    # Dataset transformations
    splitdata,
    zipdata,

    # File dataset
    FileDataset,
    isimagefile,
    fullpath,
    isfiletype,
    loadfile,

    # Registry
    DATASET_REGISTRY,
    register!,
    metadata,
    loaddataset,
    datasets,

    # Dataset implementations
    ImageNette,
    ImageWoof,

    # reexport
    getobs,
    nobs



end # module
