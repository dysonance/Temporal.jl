const DECIMALS = 4
const SHOWINT = true

function show{V,T}(io::IO, x::TS{V,T})
    if isempty(x)
        @printf(io, "Empty %s", typeof(x))
        return
    end
    nrow = size(x,1)
    ncol = size(x,2)
    intcatcher = falses(ncol)
    fields = String[string(x.fields[j]) for j=1:ncol]
    index = String[string(x.index[i]) for i=1:nrow]
    @inbounds for j = 1:ncol
        intcatcher[j] = all(trunc(x.values[:,j]) - x.values[:,j] .== 0.0) ? true : false
    end
    spacetime = strwidth(string(x.index[1])) + 2
    firstcolwidth = strwidth(string(fields[1]))
    colwidth = zeros(Int, ncol)
    if V == Bool
        colwidth += 6
    else
        @inbounds for j = 1:ncol
            colwidth[j] = max(strwidth(fields[j]), strwidth(@sprintf("%.2f", maximum(x.values[:,j]))))
        end
    end

    # Summary line
    @printf(io, "%dx%d %s: %s to %s\n\n", nrow, ncol, typeof(x), index[1], index[end])

    # Field names line
    print(io, "Index ", ^(" ", spacetime-6), fields[1], ^(" ", colwidth[1] + 2 - firstcolwidth))
    @inbounds for j = 2:length(colwidth)
        print(io, fields[j], ^(" ", colwidth[j] - strwidth(fields[j]) + 2))
    end
    println(io, "")

    # Time index & values line
    if nrow > 9
        @inbounds for i = 1:5
            print(io, x.index[i], "  ")
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, rpad(x.values[i,j], colwidth[j]+2, " "))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
        println(io, "...")
        @inbounds for i = nrow-4:nrow
            print(io, x.index[i], "  ")
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, rpad(x.values[i,j], colwidth[j]+2, " "))
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
    else
        @inbounds for i = 1:nrow
            print(io, x.index[i], "  ")
            @inbounds for j = 1:ncol
                if V == Bool
                    print(io, x.index[i], "  ")
                else
                    if intcatcher[j] & SHOWINT
                        print(io, rpad(round(Integer, x.values[i,j]), colwidth[j]+2, " "))
                    else
                        print(io, rpad(round(x.values[i,j], DECIMALS), colwidth[j]+2, " "))
                    end
                end
            end
            println(io, "")
        end
    end
end
