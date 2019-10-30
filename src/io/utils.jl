import HTTP


function isdate(t::AbstractVector{T})::Bool where {T<:TimeType}
    h = Dates.hour.(t)
    m = Dates.minute.(t)
    s = Dates.second.(t)
    ms = Dates.millisecond.(t)
    return all(h.==h[1]) && all(m.==m[1]) && all(s.==s[1]) && all(ms.==ms[1])
end

function csvresp(resp::HTTP.Response; sort::Char='d')
    @assert resp.status == 200 "Error in download request."
    rowdata = Vector{String}(split(String(resp.body), '\n'))
    header = Vector{String}(split(popfirst!(rowdata), ','))
    pop!(rowdata)
    if sort == 'd'
        reverse!(rowdata)
    elseif sort != 'a'
        error("Argument `sort` must be either 'a' (ascending) or 'd' (descending)")
    end
    N = length(rowdata)
    k = length(header)
    v = map(s -> Array{String}(split(s, ',')), rowdata)
    source_is_google = (header[1] == "\ufeffDate")
    if source_is_google
        header[1] .= "Date"
        format = Dates.DateFormat("dd-uuu-yy")
        t = map(s -> Dates.DateTime(s[1], format), v)
        t .+= Dates.Year(2000)  # instead of year 0017, take year 2017
    else
        format = Dates.DateFormat("yyyy-mm-dd")
        t = map(s -> Dates.DateTime(s[1]), v)
    end
    isdate(t) ? t = Date.(t) : nothing
    data = zeros(Float64, (N,k-1))
    if length(header) == 2 && header[2] == "Stock Splits"
        # Logic to be applied for stock splits for Yahoo Finance downloads
        @inbounds for i in 1:N
            stock_split_string = split(v[i][2], '/')
            split_a = float(stock_split_string[1])
            split_b = float(stock_split_string[2])
            is_rev_split = split_a < split_b
            data[i,1] .= split_b / split_a
        end
    else
        # Standard logic
        @inbounds for i in 1:N
            @inbounds for j in 2:k
                if v[i][j] == "" || v[i][j] == "null"
                    v[i][j] = "NaN"
                end
                data[i,j-1] = parse(Float64, v[i][j])
            end
        end
    end
    return (data, t, header)
end
