
module MPIIData

using DataDeps
using ..DLDatasets
using FileIO: load
abstract type MPII end


function loadmpiibyimage(imagefolder, annotationfolder, splits)
    # todo: implement
end

function loadmpiibyannotation(imagefolder, annotationfolder, splits)
    # todo: implement
end

# adding to registry

DLDatasets.metadata(::Type{MPII}) = (
    obstypes = ("image", "poses"),
    splits = ("train", "val"),
)

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
        "604bc9286027c072a42620d81e253959dbb585a8b84bf246a98905d583075e39";
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
        "base",
        (splits) -> loadimagenette(
            datadep"mpii_images", datadep"mpii_annotations", splits)
    )

end

export ImageNette


end
