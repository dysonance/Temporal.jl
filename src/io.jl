using Temporal
const YAHOO_URL = "http://real-chart.finance.yahoo.com/table.csv"
const QUANDL_URL = "https://www.quandl.com/api/v3/datasets"

# haspkg(pkg::String)::Bool = isdir("$(Pkg.dir())/$pkg")

function matchcount(s::String, c::Char=',')
    x = 0
    @inbounds for i = 1:length(s)
        if s[i] == c
            x += 1
        end
    end
    return x
end

function tsread(file::String; dlm::Char=',', header::Bool=true, eol::Char='\n',
                indextype::Type=Date, format::String="yyyy-mm-dd")
    @assert indextype == Date || indextype == DateTime "Argument `indextype` must be either `Date` or `DateTime`."
    csv = Vector{String}(split(readstring(file), eol))
    if csv[end] == ""
        pop!(csv)  # remove final blank line
    end
    if header
        fields = Vector{String}(split(shift!(csv), dlm)[2:end])
        k = length(fields)
        n = length(csv)
    else
        k = matchcount(csv[1], dlm)
        n = length(csv)
        fields = autocolname(1:k)
    end
    # Fill data
    arr = zeros(Float64, (n,k))
    idx = fill("", n)::Vector{String}
    for i = 1:n
        s = Vector{String}(split(csv[i], dlm))
        idx[i] = shift!(s)
        s[s.==""] = "NaN"
        arr[i,:] = float(s)
    end
    return ts(arr, indextype(idx), fields)
end

function tswrite(x::TS, file::String; dlm::Char=',', header::Bool=true, eol::Char='\n')
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

# ==============================================================================
# WEB INTERFACE ================================================================
# ==============================================================================

function dateconv(s::String)
    Dates.datetime2unix(Dates.DateTime(s))
end

function isdate(t::Vector{DateTime})
    h = Dates.hour(t)
    m = Dates.minute(t)
    s = Dates.second(t)
    ms = Dates.millisecond(t)
    return all(h.==h[1]) && all(m.==m[1]) && all(s.==s[1]) && all(ms.==ms[1])
end

function csvresp(resp; sort::String="des")
    @assert resp.status == 200 "Error in download request."
    rowdata = Vector{String}(split(readstring(resp), '\n'))
    header = Vector{String}(split(shift!(rowdata), ','))
    pop!(rowdata)
    if sort == "des"
        reverse!(rowdata)
    end
    N = length(rowdata)
    k = length(header)
    data = zeros(Float64, (N,k-1))
    v = map(s -> Array{String}(split(s, ',')), rowdata)
    t = map(s -> Dates.DateTime(s[1]), v)
    isdate(t) ? t = Date(t) : nothing
    @inbounds for i = 1:N
        j = (v[i] .== "")
        v[i][find(j)] = "NaN"
        data[i,:] = float(v[i][2:k])
    end
    return (data, t, header)
end

# ==============================================================================
# QUANDL INTERFACE =============================================================
# ==============================================================================

function quandl_auth{T<:String}(key::T="")
    authfile = "$(Pkg.dir())/quandl-auth"
    if key == ""
        if isfile(authfile)
            key = readstring(authfile)
        end
    else
        f = open(authfile, "w")
        write(f, key)
        close(f)
    end
    return key
end

"""
`quandl(code::String;
        from::String="",
        thru::String="",
        freq::String="daily",
        calc::String="none",
        sort::String="asc",
        rows::Int=0,
        auth::String=quandl_auth())`

Quandl data download
"""
function quandl(code::String;
                from::String="",
                thru::String="",
                freq::String="daily",
                calc::String="none",
                sort::String="asc",
                rows::Int=0,
                auth::String=quandl_auth())
    # Check arguments =========================================================
    @assert from=="" || (from[5]=='-' && from[8]=='-') "Argument `from` has invlalid format."
    @assert thru=="" || (thru[5]=='-' && thru[8]=='-') "Argument `thru` has invlalid format."
    @assert freq in ["daily","weekly","monthyl","quarterly","annual"] "Invalid `freq` argument."
    @assert calc in ["none","diff","rdiff","cumul","normalize"] "Invalid `calc` argument."
    @assert sort  == "asc" || sort == "des" "Argument `sort` must be either \"asc\" or \"des\"."
    if rows != 0 && (from != "" || thru != "")
        error("Cannot specify `rows` and date range (`from` or `thru`).")
    end
    # Format URL ===============================================================
    if rows == 0
        fromstr = from == "" ? "" : "&start_date=$from"
        thrustr = thru == "" ? "" : "&end_date=$thru"
        url = "$QUANDL_URL/$code.csv?$(fromstr)$(thrustr)&order=$sort&collapse=$freq&transform=$calc&api_key=$auth"
    else
        url = "$QUANDL_URL/$code.csv?&rows=$rows&order=$sort&collapse=$freq&transform=$calc&api_key=$auth"
    end
    indata = csvresp(get(url), sort=sort)
    return ts(indata[1], indata[2], indata[3][2:end])
end

"""
quandl_meta(database::String, dataset::String)
Quandl dataset metadata downloaded into a Julia Dict
"""
function quandl_meta(database::String, dataset::String)
    resp = get("$QUANDL_URL/$database/$dataset/metadata.json")
    @assert resp.status == 200 "Error downloading metadata from Quandl."
    return JSON.parse(readstring(resp))["dataset"]
end

"""
quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)
Search Quandl for data in a given database, `db`, or matching a given query, `qry`.
"""
function quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)
    @assert db!="" || qry!="" "Must enter a database or a search query."
    dbstr = db   == "" ? "" : "database_code=$db&"
    qrystr = qry  == "" ? "" : "query=$(replace(qry, ' ', '+'))&"
    resp = get("$QUANDL_URL.json?$(dbstr)$(qrystr)per_page=$perpage&page=$pagenum")
    @assert resp.status == 200 "Error retrieving search results from Quandl"
    return JSON.parse(readstring(resp))
end

# ==============================================================================
# YAHOO INTERFACE ==============================================================
# ==============================================================================

function yahoo(symb::String;
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::Char='d')
    @assert freq in ['d','w','m','v'] "Argument `freq` must be in ['d','w','m','v']"
    @assert from[5] == '-' && from[8] == '-' "Argument `from` has invalid date format."
    @assert thru[5] == '-' && thru[8] == '-' "Argument `thru` has invalid date format."
    m = Base.parse(Int, from[6:7]) - 1
    a = m<10 ? string("0",m) : string(m)
    b = from[9:10]
    c = from[1:4]
    m = Base.parse(Int, thru[6:7]) - 1
    d = m<10 ? string("0",m) : string(m)
    e = thru[9:10]
    f = thru[1:4]
    indata = csvresp(get("$YAHOO_URL?s=$symb&a=$a&b=$b&c=$c&d=$d&e=$e&f=$f&g=$freq&ignore=.csv"))
    return ts(indata[1], indata[2], indata[3][2:end])
end

function yahoo(syms::Vector{String};
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::Char='d')
    out = Dict()
    for s = syms
        out[s] = yahoo(s, from=from, thru=thru, freq=freq)
    end
    return out
end
