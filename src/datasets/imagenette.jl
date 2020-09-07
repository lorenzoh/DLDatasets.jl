
module ImageNetteData

using DataDeps
using ..DLDatasets
using FileIO: load
abstract type ImageNette end


function loadimagenette(folder::String, splits)
    dataset = FileDataset(folder, (loadfile, file -> file.parent.name), filterfn = isimagefile)
    return splitdata(dataset, splits) do file
        file.parent.parent.name
    end
end

# adding to registry

DLDatasets.metadata(::Type{ImageNette}) = (
    obstypes = ("image", "category"),
    splits = ("train", "val"),
)

function __init__()
    register(DataDep(
        "imagenette2_160",
        """
        ImageNette2 (160px) as published on https://github.com/fastai/imagenette.

        Based on:
        @inproceedings{imagenet_cvpr09,
        AUTHOR = {Deng, J. and Dong, W. and Socher, R. and Li, L.-J. and Li, K. and Fei-Fei, L.},
        TITLE = {{ImageNet: A Large-Scale Hierarchical Image Database}},
        BOOKTITLE = {CVPR09},
        YEAR = {2009},
        BIBSOURCE = "http://www.image-net.org/papers/imagenet_cvpr09.bib"}
        """,
        "https://s3.amazonaws.com/fast-ai-imageclas/imagenette2-160.tgz",
        "88daccb09b6fce93f45e6c09ddeb269cce705549e6bff322092a2a5a11489863";
        post_fetch_method = unpack,
    ))
    register(DataDep(
        "imagenette2_320",
        """
        ImageNette2 (320px) as published on https://github.com/fastai/imagenette.

        Based on:
        @inproceedings{imagenet_cvpr09,
        AUTHOR = {Deng, J. and Dong, W. and Socher, R. and Li, L.-J. and Li, K. and Fei-Fei, L.},
        TITLE = {{ImageNet: A Large-Scale Hierarchical Image Database}},
        BOOKTITLE = {CVPR09},
        YEAR = {2009},
        BIBSOURCE = "http://www.image-net.org/papers/imagenet_cvpr09.bib"}
        """,
        "https://s3.amazonaws.com/fast-ai-imageclas/imagenette2-320.tgz",
        "5020a9130cea0348272823cb12d2db7e981c6f2afa3dce71ccd5b8013005c55e";
        post_fetch_method = unpack,
    ))

    register!(
        DATASET_REGISTRY,
        ImageNette,
        "v2_160px",
        (splits) -> loadimagenette(datadep"imagenette2_160", splits)
    )

    register!(
        DATASET_REGISTRY,
        ImageNette,
        "v2_320px",
        (splits) -> loadimagenette(datadep"imagenette2_320", splits)
    )

end

export ImageNette


end
