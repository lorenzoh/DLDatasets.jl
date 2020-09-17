
module MPIIData

export MPII

using DataDeps
using Parameters
using JSON3
using LearnBase
using ..DLDatasets
using StaticArrays
using FileIO: load



# adding to registry


function __init__()
    register(DataDep(
        "mpii_images",
        """
        MPII dataset as published on "http://human-pose.mpi-inf.mpg.de/#download"

        LICENSE
        -------
        Copyright (c) 2015, Max Planck Institute for Informatics
        All rights reserved.

        Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        """,
        "https://datasets.d2.mpi-inf.mpg.de/andriluka14cvpr/mpii_human_pose_v1.tar.gz",
        "6d26fbf89f49a7aeff4aa5f98123763f334693806b98eb15630f57a0b50998ce";
        post_fetch_method = unpack,
    ))

    register(DataDep(
        "mpii_annotations",
        """
        MPII dataset as published on "http://human-pose.mpi-inf.mpg.de/#download"

        LICENSE
        -------
        Copyright (c) 2015, Max Planck Institute for Informatics
        All rights reserved.

        Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        """,
        [
            "https://gist.github.com/lorenzoh/7579e9493775ba2dd4018c7cf44aa112/raw/0b7c4df4d736bc7bcb349abea57edc66b6baa936/mpiivalid.json",
            "https://gist.github.com/lorenzoh/ed17568b9a5440b60e19da6e5efabf73/raw/aa2a7afefa4672429e2cafb0d219caed4a27bce1/mpiitrain.json"
        ],
        "604bc9286027c072a42620d81e253959dbb585a8b84bf246a98905d583075e39";
    ))


    register!(
        DATASET_REGISTRY,
        MPII,
        "images",
        (splits) -> loadmpii(
            ByImage,
            datadep"mpii_images",
            datadep"mpii_annotations",
            splits)
    )

    register!(
        DATASET_REGISTRY,
        MPII,
        "annotations",
        (splits) -> loadmpii(
            ByAnnotation,
            datadep"mpii_images",
            datadep"mpii_annotations",
            splits)
    )

end

abstract type By end
struct ByImage <: By end
struct ByAnnotation <: By end

# MPII by image


function loadmpii(by::Type{<:By}, imagefolder, annotationfolder, splits)
    trainfile = joinpath(annotationfolder, "mpiitrain.json")
    valfile = joinpath(annotationfolder, "mpiivalid.json")

    trainanns = open(JSON3.read, trainfile);
    valanns = open(JSON3.read, valfile);
    anns = vcat(trainanns, valanns)

    isvalid = vcat(zeros(length(trainanns)), trues(length(valanns)))
    imagetoanns = getimagetoanns(anns)

    ds = MPII{by}(
        imagefolder,
        anns,
        imagetoanns,
        collect(keys(imagetoanns)),
        isvalid)


end


@with_kw struct MPII{By}
    imagefolder::String
    annots
    imagetoannot::Dict{String, Vector{Int}}
    images::Vector{String}
    isvalid::Vector{Bool}
end

LearnBase.nobs(ds::MPII{<:ByImage}) = length(ds.images)
function LearnBase.getobs(ds::MPII{ByImage}, idx)
    annots = [ds.annots[i] for i in ds.imagetoannot[ds.images[idx]]]
    poses = [parsepose(ann.joints) for ann in annots]

    return (
        image = load(joinpath(ds.imagefolder, ds.images[idx]), view = true),
        poses = poses
    )
end

function LearnBase.getobs(ds::MPII{ByAnnotation}, idx)
    annot = ds.annots[idx]
    otherannots = [ds.annots[i] for i in ds.imagetoannot[annot.image] if i != idx]
    (; annot, otherannots)
end

# dataset information

DLDatasets.metadata(::Type{MPII}) = (
    obstypes = ("image", "poses"),
    splits = (),
    skeleton = [
        (3, 2),
        (15, 16),
        (12, 11),
        (8, 7),
        (9, 10),
        (9, 8),
        (5, 6),
        (7, 4),
        (7, 3),
        (4, 5),
        (9, 14),
        (9, 13),
        (14, 15),
        (13, 12),
        (2, 1)
    ]
)

# Utils


function getimagetoanns(anns)
    imagetoanns = Dict{String, Vector{Int}}()
    for (idx, ann) in enumerate(anns)
        if !haskey(imagetoanns, ann.image)
            imagetoanns[ann.image] = Int[]
        end
        push!(imagetoanns[ann.image], idx)
    end

    return imagetoanns
end

parsepose(joints)::Vector{Union{Nothing, SVector{2, Float32}}} = parsejoint.(joints)

function parsejoint((x, y))
    return (y, x) == (-1, -1) ? nothing : SVector{2, Float32}(y+1, x+1)
end

end  # module
