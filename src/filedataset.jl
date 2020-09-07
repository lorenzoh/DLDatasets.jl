

struct FileDataset
    tree::FileTree
    loadfn
    nodes
end

Base.show(io::IO, ds::FileDataset) = print(io, "FileDataset with $(nobs(ds)) files")

function FileDataset(folder::String, loadfn; filterfn = nothing)
    tree = FileTree(folder)
    if !isnothing(filter)
        tree = filter(filterfn, tree; dirs = false)
    end
    return FileDataset(tree, loadfn, nodes(tree, dirs = false))
end

FileDataset(loadfn, folder::String; filterfn = nothing) =
    FileDataset(folder, loadfn; filterfn = filterfn)


LearnBase.nobs(ds::FileDataset) = length(ds.nodes)
LearnBase.getobs(ds::FileDataset, idx::Int) = loadobs(ds.loadfn, ds.nodes[idx])


Base.filter(f, ds::FileDataset) = FileDataset(filter(f, ds.tree; dirs = false), ds.loadfn)

## File utilities

# nfiles
nfiles(tree::FileTree) = length(nodes(tree; dirs = false))

# isimagefile
isimagefile(file::File) = isimagefile(file.name)
isimagefile(file::String) = occursin(IMAGEFILE_REGEX, lowercase(file))
const IMAGEFILE_REGEX = r"\.(gif|jpe?g|tiff?|png|webp|bmp)$"

# isfiletype
isfiletype(file::File, filetype::String) = isfiletype(file.name, filetype)
function isfiletype(file::String, filetype::String)
    return endswith(file, _withdot(filetype))
end
isfiletype(suffix) = file -> isfiletype(file, suffix)

_withdot(filetype::String) = startswith(filetype, '.') ? filetype : string('.', filetype)

fullpath(file::File)::String = string(path(file))

loadfile(file::File) = loadfile(fullpath(file))
loadfile(file) = load(file)
