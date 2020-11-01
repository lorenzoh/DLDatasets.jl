
module COCOData

export COCO

using DataDeps
using LearnBase
using StaticArrays
using FileIO: load, save
using JSON3
using StructArrays

using ..DLDatasets

export COCOKeypoints

const COCO_COPYRIGHT = """
Terms of Use
Annotations & Website
The annotations in this dataset along with this website belong to the COCO Consortium and are licensed under a Creative Commons Attribution 4.0 License.

Images
The COCO Consortium does not own the copyright of the images. Use of the images must abide by the Flickr Terms of Use. The users of the images accept full responsibility for the use of the dataset, including but not limited to the use of any copies of copyrighted images that they may create from the dataset.

Software
Copyright (c) 2015, COCO Consortium. All rights reserved. Redistribution and use software in source and binary form, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the COCO Consortium nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE AND ANNOTATIONS ARE PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""


function __init__()
    register(DataDep(
        "coco_keypoint_annotations",
        COCO_COPYRIGHT,
        "http://images.cocodataset.org/annotations/annotations_trainval2017.zip",
        "113a836d90195ee1f884e704da6304dfaaecff1f023f49b6ca93c4aaae470268",
        post_fetch_method = path -> (unpack(path); init_coco_annotations(path))
    ))

    register(DataDep(
        "coco_keypoint_images",
        COCO_COPYRIGHT,
        [
            "http://images.cocodataset.org/zips/train2017.zip",
            "http://images.cocodataset.org/zips/val2017.zip",
        ],
        [
            "",
            "",
        ],
        post_fetch_method = unpack
    ))

    register!(
        DATASET_REGISTRY,
        COCOKeypoints,
        "byimage",
        (splits; imagefolder = datadep"coco_keypoint_images") -> COCOKeypoints(
            ByImage,
            imagefolder,
            load(joinpath(datadep"coco_keypoint_annotations", "annotations.jld2"))["annotations"])
    )

    register!(
        DATASET_REGISTRY,
        COCOKeypoints,
        "byannotation",
        (splits; imagefolder = datadep"coco_keypoint_images") -> COCOKeypoints(
            ByAnnotation,
            imagefolder,
            load(joinpath(datadep"coco_keypoint_annotations", "annotations.jld2"))["annotations"])
    )
end


abstract type By end
struct ByImage <: By end
struct ByAnnotation <: By end


struct COCOKeypoints{By}
    imagefolder::String
    annotations
    ids::Vector{Int}
    image_ids::Vector{Int}
   # Maps image ids to annotation ids
    imagemap::Dict{Int, Vector{Int}}
    # Maps annotations ids to index in `annotations`
    id2idxmap
end

Base.show(io::IO, ds::COCOKeypoints) = print(io, "COCOKeypoints() with $(nobs(ds)) observations")

DLDatasets.metadata(::Type{COCOKeypoints}) = (
    splits = (),
    skeleton = [
        (16, 14),
        (14, 12),
        (17, 15),
        (15, 13),
        (12, 13),
        (6, 12),
        (7, 13),
        (6, 7),
        (6, 8),
        (7, 9),
        (8, 10),
        (9, 11),
        (2, 3),
        (1, 2),
        (1, 3),
        (2, 4),
        (3, 5),
        (4, 6),
        (5, 7)
    ],
    keypointlabels = [
        "nose","left_eye","right_eye","left_ear","right_ear",
        "left_shoulder","right_shoulder","left_elbow","right_elbow",
        "left_wrist","right_wrist","left_hip","right_hip",
        "left_knee","right_knee","left_ankle","right_ankle"
    ]
)

function COCOKeypoints(
        by::Type{<:By},
        imagefolder,
        annotations;
        filterfn = (_) -> true,
        minkeypoints = 1)
    ids = filter(
        annot -> filterfn(annot) && annot.num_keypoints >= minkeypoints,
        annotations).id
    imagemap = makeimagemap(annotations.id, annotations.image_id)
    image_ids = collect(keys(imagemap))
    id2idxmap = Dict(id => idx for (idx, id) in enumerate(annotations.id))
    return COCOKeypoints{by}(imagefolder, annotations, ids, image_ids, imagemap, id2idxmap)
end


# LearnBase interface for by-image dataset
LearnBase.nobs(ds::COCOKeypoints{ByImage}) = length(keys(ds.imagemap))
function LearnBase.getobs(ds::COCOKeypoints{ByImage}, idx)
    ids = ds.imagemap[ds.image_ids[idx]]
    idxs = [ds.id2idxmap[id] for id in ids]
    annots = [ds.annotations[idx] for idx in idxs]
    imagepath = getimagepath(ds.imagefolder, annots[1].image_id, annots[1].isvalid)

    return (; imagepath, annots)
end

# LearnBase interface for by-annotation dataset
LearnBase.nobs(ds::COCOKeypoints{ByAnnotation}) = length(ds.ids)
function LearnBase.getobs(ds::COCOKeypoints{ByAnnotation}, idx)
    annot = ds.annotations[ds.id2idxmap[ds.ids[idx]]]
    ids = ds.imagemap[annot.image_id]
    otheridxs = [ds.id2idxmap[id] for id in ids if id != annot.id]
    otherannots = [ds.annotations[idx] for idx in otheridxs]
    imagepath = getimagepath(ds.imagefolder, annot.image_id, annot.isvalid)

    (; imagepath, annot, otherannots)
end

getimagepath(folder, image_id, isvalid) = joinpath(
    folder,
    isvalid ? "val2017" : "train2017",
    "$(lpad(image_id, 12, "0")).jpg"
)

# # Dataset preparation

function init_coco_annotations(path; remove_download = false)
    data = parseallannotations(joinpath(path, "annotations"))
    save(
        joinpath(path, "annotations.jld2"),
        Dict(
            "annotations" => data,
        )
    )
    if remove_download
        rm(joinpath(path, "annotations"), recursive=true)
    end
end


function parseallannotations(folder)
    trainpath = joinpath(folder, "person_keypoints_train2017.json")
    validpath = joinpath(folder, "person_keypoints_val2017.json")

    traindata = parseannotations(trainpath, isvalid = false)
    validdata = parseannotations(validpath, isvalid = true)

    return vcat(traindata, validdata)
end


"""
    makeimagemap(ids, image_ids)

Creates a Dict mapping each image_id to a vector of corresponding
annotation ids.
"""
function makeimagemap(ids, image_ids)
    imagemap = Dict{Int, Vector{Int64}}()
    for (id, image_id) in zip(ids, image_ids)
        if !haskey(imagemap, image_id)
            imagemap[image_id] = Int64[]
        end
        push!(imagemap[image_id], id)
    end
    return imagemap
end


# Parsing

function parseannotations(path; isvalid = false)
    jsondata = JSON3.read(read(path)).annotations
    return parse_to_arrays(jsondata; isvalid = isvalid)
end


function parse_to_arrays(annotations_json; isvalid = false)
    columns = [:num_keypoints, :area, :keypoints, :bbox, :id, :image_id]
    data = Dict(s => [ann[s] for ann in annotations_json] for s in columns)
    return StructArray((
        id = data[:id],
        image_id = data[:image_id],
        num_keypoints = UInt8.(data[:num_keypoints]),
        area = Float32.(data[:area]),
        bbox = parsebbox.(data[:bbox]),
        keypoints = parsekeypoints.(data[:keypoints]),
        isvalid = fill(isvalid, length(data[:num_keypoints])),
    ))
end


function parsebbox(bbox)
    x, y, w, h = bbox
    return [SVector{2,Float16}(y + 1, x + 1), SVector{2,Float16}(y + h, x + w)]
end


function parsekeypoints(keypoints)
    xs = @view keypoints[1:3:end]
    ys = @view keypoints[2:3:end]
    ids = @view keypoints[3:3:end]
    pose = Vector{Union{Nothing, SVector{2, Float16}}}(nothing, length(xs))

    for (k, (x, y, id)) in enumerate(zip(xs, ys, ids))
        if id != 0
            pose[k] = SVector{2,Float16}(y + 1, x + 1)
        end
    end

    return pose
end


end  # module
