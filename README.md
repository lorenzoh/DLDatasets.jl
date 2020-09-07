# DLDatasets.jl

Quickly load datasets for deep learning.

DLDatasets.jl provides a convenient way to download and load large deep learning datasets that do not fit into memory. It also provides building blocks for building your own datasets, for example `FileDataset`.

This package uses MLDataPattern.jl's [data container interface](https://mldatapatternjl.readthedocs.io/en/latest/documentation/container.html). The underlying abstractions are inspired by fast.ai's [DataBlock API](https://docs.fast.ai/tutorial.datablock).
