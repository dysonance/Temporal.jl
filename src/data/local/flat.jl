"""
    tsread(file::String;dlm::Char=',',header::Bool=true,eol::Char='\\n',indextype::Type=Date,format::String="yyyy-mm-dd")::TS

Read contents from a text file into a TS object.

# Arguments
- `file::String`: path to the input file
Optional args:
- `dlm::Char=','`: delimiter used to separate columns
- `header::Bool=true`: whether a header row exists
- `eol::Char='\\n'`: character used to specify ends of lines
- `indextype::Type=Date`: DateTime or Date
- `format::String="yyyy-mm-dd"`: format used to parse the index

# Example

    X = tsread("data.csv")

"""
function tsread(file::String; dlm::Char=',', header::Bool=true, eol::Char='\n', indextype::Type=Date, format::String="yyyy-mm-dd")::TS
    @assert indextype == Date || indextype == DateTime "Argument `indextype` must be either `Date` or `DateTime`."
    csv = Vector{String}(split(read(file, String), eol))
    if csv[end] == ""
        pop!(csv)  # remove final blank line
    end
    if header
        fields = Vector{String}(split(popfirst!(csv), dlm)[2:end])
        k = length(fields)
        n = length(csv)
    else
        # k = matchcount(csv[1], dlm)
        k = sum([csv[1][i] == dlm for i in 1:length(csv[1])])
        n = length(csv)
        fields = autocolname(1:k)
    end
    # Fill data
    arr = zeros(Float64, (n,k))
    idx = fill("", n)::Vector{String}
    for i = 1:n
        s = Vector{String}(split(csv[i], dlm))
        idx[i] = popfirst!(s)
        s[s.==""] .= "NaN"
        for j in 1:length(s)
            arr[i,j] = parse(Float64, s[j])
        end
    end
    return TS(arr, indextype.(idx), fields)
end

"""
    tswrite(x::TS,file::String;dlm::Char=',',header::Bool=true,eol::Char='\\n')::Nothing

Write time series data to a text file.

# Arguments
- `x::TS`: time series object to write to a file
- `file::String`: filepath to which object shall be written
Optional args:
- `dlm::Char=','`: delimiter used to separate columns
- `header::Bool=true`: whether the object's `fields` member should be included as a header row in the output file
- `eol::Char='\\n'`: character used to specify ends of lines

# Example

    X = TS(randn(252, 4))
    tswrite(X, "data.csv")

"""
function tswrite(x::TS, file::String; dlm::Char=',', header::Bool=true, eol::Char='\n')::Nothing
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

