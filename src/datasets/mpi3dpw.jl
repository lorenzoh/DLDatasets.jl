module MPI3DPWData

using Glob
using CoordinateTransformations
using PoseEstimation
using Images
using LearnBase
using LearnBase: getobs, nobs
using PyCall
using Parameters
const pickle = pyimport("pickle")
const py = PyCall.builtin
using StaticArrays

using ..DLDatasets

function __init__()

    # TODO: add DataDeps including copyright notice

    # TODO: register dataset
    #=
    register!(
        DATASET_REGISTRY,
        MPI3DPW,
        "byannotation",
        (splits; imagefolder = datadep"coco_keypoint_images") -> COCOKeypoints(
            ByImage,
            imagefolder,
            load(joinpath(datadep"coco_keypoint_annotations", "annotations.jld2"))["annotations"])
    )
    =#

end

## Constants

@with_kw_noshow struct MPI3DPW
    sequences
    imagefolder
end


Base.show(io::IO, ds::MPI3DPW) = print(io, "MPI3DPW() with $(nobs(ds)) observations")


function MPI3DPW(seqfolder::AbstractString, imagefolder::AbstractString)
    return MPI3DPW(
        [loadsequence(path) for path in glob("*.pkl", seqfolder)],
        imagefolder
    )
end

DLDatasets.metadata(::Type{MPI3DPW}) = (
    splits = (),
    skeleton = [
        (1, 2),
        (1, 3),
        (1, 4),
        (2, 5),
        (3, 6),
        (4, 7),
        (5, 8),
        (6, 9),
        (7, 10),
        (8, 11),
        (9, 12),
        (10, 14),
        (10, 15),
        (10, 13),
        (13, 16),
        (14, 17),
        (15, 18),
        (17, 19),
        (18, 20),
        (19, 21),
        (20, 22),
        (21, 23),
        (22, 24),
    ],
    keypointlabels = [
        "pelvis",
        "hip_left",
        "hip_right",
        "spine_bottom",
        "knee_left",
        "knee_right",
        "spine_middle",
        "ankle_left",
        "ankle_right",
        "spine_top",
        "toe_left",
        "toe_right",
        "head",
        "clavicle_left",
        "clavicle_right",
        "head_top",
        "shoulder_left",
        "shoulder_right",
        "elbow_left",
        "elbow_right",
        "wrist_left",
        "wrist_right",
        "hand_left",
        "hand_right",
    ],
)


nframes(sequence) = size(sequence["cam_poses"], 1)
nactors(sequence) = length(sequence["poses"])
nsamples(sequence) = nactors(sequence) * nframes(sequence)


LearnBase.nobs(ds::MPI3DPW) = sum(nsamples(seq) for seq in ds.sequences)


function LearnBase.getobs(ds::MPI3DPW, idx::Int)
    seqidx, actoridx, frameidx = _findindex(ds.sequences, idx)
    return LearnBase.getobs(ds, seqidx, actoridx, frameidx)
end


function LearnBase.getobs(ds::MPI3DPW, seqidx, actoridx, frameidx)
    seq = ds.sequences[seqidx]
    positions = view(seq["jointPositions"][actoridx], frameidx, :)
    positions = reinterpret(SVector{3, eltype(positions)}, positions)

    return (
        img_frame_id = seq["img_frame_ids"][frameidx],
        cam_intrinsics = seq["cam_intrinsics"],
        v_template_clothed = seq["v_template_clothed"][actoridx],
        betas = seq["betas"][actoridx],
        campose_valid = Bool(seq["campose_valid"][actoridx][frameidx]),
        trans = view(seq["trans"][actoridx], frameidx, :),
        pose = view(seq["poses"][actoridx], frameidx, :),
        gender = seq["genders"][actoridx],
        sequence = seq["sequence"],
        pose2d = view(seq["poses2d"][actoridx], frameidx, :, :),
        betas_clothed = seq["betas_clothed"][actoridx],
        jointPositions = positions,
        cam_pose = view(seq["cam_poses"], frameidx, :, :),
        imagepath = imagepath(ds.imagefolder, seq["sequence"], frameidx),
    )
end


## IO


function loadsequence(file)
    pickle = pyimport("pickle")
    return pickle.load(PyCall.builtin.open(file, "rb"), encoding = "bytes")
end

imagepath(folder, seqname, frame) = joinpath(
    folder, seqname, "image_$(lpad(string(frame), 5, '0')).jpg")

## Utils


function _findindex(sequences, idx)
    idx -= 1
    seqidx = 0
    while idx >= (n = nsamples(sequences[seqidx+1]))
        idx -= n
        seqidx += 1
    end
    nf = nframes(sequences[seqidx+1])
    actoridx = idx ÷ nf
    frameidx = idx % nf
    return seqidx + 1, actoridx + 1, frameidx + 1
end


end  # module
