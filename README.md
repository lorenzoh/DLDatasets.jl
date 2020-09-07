# DLDatasets.jl

Quickly load datasets for deep learning.

DLDatasets.jl provides a convenient way to download and load large deep learning datasets that do not fit into memory. It also provides building blocks for building your own datasets, for example `FileDataset`.

This package uses MLDataPattern.jl's [data container interface](https://mldatapatternjl.readthedocs.io/en/latest/documentation/container.html). The underlying abstractions are inspired by fast.ai's [DataBlock API](https://docs.fast.ai/tutorial.datablock). To iterate over data containers quickly, you could use [DataLoaders.jl](https://github.com/lorenzoh/DataLoaders.jl)

DLDatasets.jl is still WIP. Support for tabular datasets is coming.

## Usage

Install and import:

```julia
]add https://github.com/lorenzoh/DLDatasets.jl
using DLDatasets
```

Load the low-resolution version of ImageNette and load an observation:

```julia
ds = loaddataset(ImageNette, "v2_160px")
image, label = getobs(ds, 1)
```

Load different dataset splits:

```julia
trainds = loaddataset(ImageNette, "v2_160px", split = "train")
trainds, valds = loaddataset(ImageNette, "v2_160px", split = ("train", "val"))
```

List available datasets and their tags and splits:

```julia
datasets()
```

Iterate over observations fast as the wind:

```julia
]add https://github.com/lorenzoh/DataLoaders.jl
using DLDatasets: eachobsparallel

for obs in eachobsparallel(ds)
    # do stuff
end
```

## Datasets

Use `DLDatasets.datasets()` to get a list of all datasets.

The following datasets with the corresponding tags are implemented.

- `ImageNette`
  - "v2_160px"
  - "v2_320px"
- `ImageWoof`
  - "v2_160px"
  - "v2_320px"

