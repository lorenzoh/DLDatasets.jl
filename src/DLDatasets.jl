module DLDatasets


using FileTrees
import FileIO: load
using LearnBase
using Parameters





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
include("datasets/coco.jl")
using .COCOData
include("datasets/mpii.jl")
using .MPIIData
include("datasets/mpi3dpw.jl")
using .MPI3DPWData
include("datasets/pets.jl")
using .PetsData


export
    # Dataset transformations
    catdata,
    mapdata,
    splitdata,

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
    MPII,
    COCOKeypoints,

    # reexport
    getobs,
    nobs



end # module
