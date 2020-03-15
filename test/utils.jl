function findFilesMaching(pathern::Regex, path::String)
    f = readdir(path)

    idx = findall(x->occursin(pathern,x), f)
    fs = f[idx]
    files = []
    for x in fs
        push!(files,"$path/$x")
    end
    files
end
