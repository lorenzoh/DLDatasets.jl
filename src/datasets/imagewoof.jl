module ImageWoofData

using DataDeps
using ..DLDatasets
using FileIO: load
abstract type ImageWoof end


function loadimagewoof(folder::String, splits)
    dataset = FileDataset(folder, (loadfile, file -> file.parent.name), filterfn = isimagefile)
    return splitdata(dataset, splits) do file
        file.parent.parent.name
    end
end

# adding to registry

DLDatasets.metadata(::Type{ImageWoof}) = (
    obstypes = ("image", "category"),
    splits = ("train", "val"),
)

function __init__()
    register(DataDep(
        "imagewoof2_160",
        """
        ImageWoof2 (160px) as published on https://github.com/fastai/imagenette.

        Based on:
        @inproceedings{imagenet_cvpr09,
        AUTHOR = {Deng, J. and Dong, W. and Socher, R. and Li, L.-J. and Li, K. and Fei-Fei, L.},
        TITLE = {{ImageNet: A Large-Scale Hierarchical Image Database}},
        BOOKTITLE = {CVPR09},
        YEAR = {2009},
        BIBSOURCE = "http://www.image-net.org/papers/imagenet_cvpr09.bib"}
        """,
        "https://s3.amazonaws.com/fast-ai-imageclas/imagewoof2-160.tgz",
        "663c22f69c2802d85e2a67103c017e047096702ffddf9149a14011b7002539bf";
        post_fetch_method = unpack,
    ))
    register(DataDep(
        "imagewoof2_320",
        """
        ImageWoof2 (320px) as published on https://github.com/fastai/imagenette.

        Based on:
        @inproceedings{imagenet_cvpr09,
        AUTHOR = {Deng, J. and Dong, W. and Socher, R. and Li, L.-J. and Li, K. and Fei-Fei, L.},
        TITLE = {{ImageNet: A Large-Scale Hierarchical Image Database}},
        BOOKTITLE = {CVPR09},
        YEAR = {2009},
        BIBSOURCE = "http://www.image-net.org/papers/imagenet_cvpr09.bib"}
        """,
        "https://s3.amazonaws.com/fast-ai-imageclas/imagewoof2-320.tgz",
        "4e4905ed7643120daaf9bf3b2ef7f3a7e8396d9bdaf254a38c6f01f618b4973d";
        post_fetch_method = unpack,
    ))

    register!(
        DATASET_REGISTRY,
        ImageWoof,
        "v2_160px",
        (splits) -> loadimagewoof(datadep"imagewoof2_160", splits)
    )

    register!(
        DATASET_REGISTRY,
        ImageWoof,
        "v2_320px",
        (splits) -> loadimagewoof(datadep"imagewoof2_320", splits)
    )

end

export ImageWoof


end
