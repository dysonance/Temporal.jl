
"""
Read contents from a text file into a TS object.

`tsread(file::String; dlm::Char=',', header::Bool=true, eol::Char='\\n', indextype::Type=Date, format::String="yyyy-mm-dd")`


*Example*

```
julia> tsread(Pkg.dir("Temporal") * "/data/corn.csv")
14396x8 Temporal.TS{Float64,Date}: 1959-07-01 to 2016-08-30
Index       Open    High    Low     Last    Change  Settle  Volume    OpenInterest
1959-07-01  120.2   120.3   119.6   119.7   NaN     119.7   3952.0    13997.0
1959-07-02  119.6   120.0   119.2   119.6   NaN     119.6   2223.0    14047.0
1959-07-06  119.4   119.5   117.7   118.0   NaN     118.0   3121.0    14206.0
1959-07-07  118.1   118.5   118.0   118.3   NaN     118.3   3540.0    14142.0
1959-07-08  118.4   118.5   117.3   117.3   NaN     117.3   2922.0    14353.0
1959-07-09  117.2   118.3   116.6   118.2   NaN     118.2   3479.0    15051.0
⋮
2016-08-24  328.25  330.5   325.5   327.0   1.0     327.5   59855.0   178092.0
2016-08-25  327.0   328.5   322.25  323.0   4.0     323.5   73826.0   163255.0
2016-08-26  323.5   325.25  315.75  316.0   7.25    316.25  73781.0   144554.0
2016-08-29  316.25  318.75  310.75  312.0   4.5     311.75  111379.0  94676.0
2016-08-30  311.75  312.75  303.5   304.0   7.75    304.0   123102.0  66033.0
```
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
Write TS object to a text file.

`tswrite(x::TS, file::String; dlm::Char=',', header::Bool=true, eol::Char='\\n')`
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

