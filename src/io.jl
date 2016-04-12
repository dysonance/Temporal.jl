using Temporal

function matchcount(s::ASCIIString, c::Char=',')
    x = 0
    @inbounds for i = 1:length(s)
        if s[i] == c
            x += 1
        end
    end
    return x
end

function tsread(file::AbstractString; dlm::Char=',', header::Bool=true, eol::Char='\n',
                indextype::Type=Date, format::ByteString="yyyy-mm-dd")
    @assert indextype == Date || indextype == DateTime "Argument `indextype` must be either `Date` or `DateTime`."
    csv = Vector{ASCIIString}(split(readall(file), eol))
    if csv[end] == ""
        pop!(csv)  # remove final blank line
    end
    if header
        fields = Vector{ASCIIString}(split(shift!(csv), dlm)[2:end])
        k = length(fields)
        n = length(csv)
    else
        k = matchcount(csv[1], dlm)
        n = length(csv)
        fields = autocolname(1:k)
    end
    # Fill data
    arr = zeros(Float64, (n,k))
    idx = fill("", n)::Vector{ASCIIString}
    for i = 1:n
        s = Vector{ASCIIString}(split(csv[i], dlm))
        idx[i] = shift!(s)
        s[s.==""] = "NaN"
        arr[i,:] = float(s)
    end
    return ts(arr, indextype(idx), fields)
end

function tswrite(x::TS, file::AbstractString; dlm::Char=',', header::Bool=true, eol::Char='\n')
    outfile = open(file, "w")
    if header
        write(outfile, "Index$(dlm)$(join(x.fields, dlm))$(eol)")
    end
    arr = x.values
    idx = x.index
    for i = 1:length(idx)
        write(outfile, "$(idx[i])$(dlm)$(join(arr[i,:],dlm))$(eol)")
    end
    close(outfile)
end
