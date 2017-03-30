using Temporal
using JSON
using Base.Dates
const YAHOO_URL = "http://real-chart.finance.yahoo.com/table.csv"
const QUANDL_URL = "https://www.quandl.com/api/v3/datasets"

# function matchcount(s::String, c::Char=',')
#     x = 0
#     @inbounds for i = 1:length(s)
#         if s[i] == c
#             x += 1
#         end
#     end
#     return x
# end

@doc """
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
""" ->
function tsread(file::String; dlm::Char=',', header::Bool=true, eol::Char='\n', indextype::Type=Date, format::String="yyyy-mm-dd")::TS
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
        idx[i] = shift!(s)
        s[s.==""] = "NaN"
        arr[i,:] = float(s)
    end
    return ts(arr, indextype(idx), fields)
end

@doc doc"""
Write TS object to a text file.

`tswrite(x::TS, file::String; dlm::Char=',', header::Bool=true, eol::Char='\\n')`
""" ->
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
    h = Dates.hour.(t)
    m = Dates.minute.(t)
    s = Dates.second.(t)
    ms = Dates.millisecond.(t)
    return all(h.==h[1]) && all(m.==m[1]) && all(s.==s[1]) && all(ms.==ms[1])
end

function csvresp(resp; sort::Char='d')
    @assert resp.status == 200 "Error in download request."
    rowdata = Vector{String}(split(readstring(resp), '\n'))
    header = Vector{String}(split(shift!(rowdata), ','))
    pop!(rowdata)
    if sort == 'd'
        reverse!(rowdata)
    elseif sort != 'a'
        error("Argument `sort` must be either 'a' (ascending) or 'd' (descending)")
    end
    N = length(rowdata)
    k = length(header)
    data = zeros(Float64, (N,k-1))
    v = map(s -> Array{String}(split(s, ',')), rowdata)
    t = map(s -> Dates.DateTime(s[1]), v)
    isdate(t) ? t = Date.(t) : nothing
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
@doc doc"""
Set up Quandl user account authorization. Run once passing your Quandl API key, and it will be saved for future use.

`quandl_auth{T<:String}(key::T="")::String`


*Example*

```
julia> quandl_auth("Your_API_Key")
"Your_API_Key"

quandl_auth()
"Your_API_Key"
""" ->
function quandl_auth{T<:String}(key::T="")::String
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

@doc doc"""
Download time series data from Quandl as a TS object.
```
quandl(code::String;
       from::String="",
       thru::String="",
       freq::String='d',
       calc::String="none",
       sort::Char='a',
       rows::Int=0,
       auth::String=quandl_auth())::TS
```


*Example*

```
julia> quandl("CHRIS/CME_CL1", from="2010-01-01", thru=string(Dates.today()), freq="annual")
8x8 Temporal.TS{Float64,Date}: 2010-12-31 to 2017-12-31
Index       Open   High    Low    Last   Change  Settle  Volume    PreviousDayOpenInterest  
2010-12-31  89.67  92.06   89.05  91.38  NaN     91.38   171010.0  311738.0                 
2011-12-31  99.78  100.16  98.61  98.83  NaN     98.83   151380.0  233377.0                 
2012-12-31  90.41  91.99   90.0   91.82  NaN     91.82   107767.0  277570.0                 
2013-12-31  99.25  99.39   98.15  98.42  NaN     98.42   100104.0  259878.0                 
2014-12-31  53.87  54.02   52.44  53.27  0.85    53.27   247510.0  309473.0                 
2015-12-31  36.81  37.79   36.22  37.07  0.44    37.04   279553.0  436421.0                 
2016-12-31  53.87  54.09   53.41  53.89  0.05    53.72   266762.0  457983.0                 
2017-12-31  48.47  49.63   48.38  49.6   1.14    49.51   540748.0  606895.0
```
""" ->
function quandl(code::String;
                from::String="",
                thru::String="",
                freq::Char='d',
                calc::String="none",
                sort::Char='a',
                rows::Int=0,
                auth::String=quandl_auth())::TS
    # Check arguments =========================================================
    @assert from=="" || (from[5]=='-' && from[8]=='-') "Argument `from` has invlalid format."
    @assert thru=="" || (thru[5]=='-' && thru[8]=='-') "Argument `thru` has invlalid format."
    @assert freq in ["daily","weekly","monthly","quarterly","annual"] "Invalid `freq` argument."
    @assert freq in ['d', 'w', 'm', 'q', 'a'] "Invalid `freq` argument (must be in ['d', 'w', 'm', 'q', 'a'])."
    @assert calc in ["none","diff","rdiff","cumul","normalize"] "Invalid `calc` argument."
    @assert sort  == 'a' || sort == 'd' "Argument `sort` must be either \'a\' or \'d\'."
    if rows != 0 && (from != "" || thru != "")
        error("Cannot specify `rows` and date range (`from` or `thru`).")
    end
    # Format URL ===============================================================
    sort_arg = (sort=='a' ? "asc" : "des")
    freq_arg = (freq=='d'?"daily":(freq=='w'?"weekly":(freq=='m'?"monthly":(freq=='q'?"quarterly":(freq=='a'?"annual":"")))))
    if rows == 0
        fromstr = from == "" ? "" : "&start_date=$from"
        thrustr = thru == "" ? "" : "&end_date=$thru"
        url = "$QUANDL_URL/$code.csv?$(fromstr)$(thrustr)&order=$sort_arg&collapse=$freq_arg&transform=$calc&api_key=$auth"
    else
        url = "$QUANDL_URL/$code.csv?&rows=$rows&order=$sort_arg&collapse=$freq_arg&transform=$calc&api_key=$auth"
    end
    indata = csvresp(get(url), sort=sort)
    return ts(indata[1], indata[2], indata[3][2:end])
end

@doc doc"""
Download Quandl metadata for a database and dataset into a Julia Dict object.

`quandl_meta(database::String, dataset::String)`
""" ->
function quandl_meta(database::String, dataset::String)::Dict{String,Any}
    resp = get("$QUANDL_URL/$database/$dataset/metadata.json")
    @assert resp.status == 200 "Error downloading metadata from Quandl."
    return JSON.parse(readstring(resp))["dataset"]
end

@doc doc"""
Search Quandl for data in a given database, `db`, or matching a given query, `qry`.

`quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)`
""" ->
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
@doc doc"""
Download stock price data from Yahoo! Finance into a TS object.

`yahoo(symb::String; from::String="1900-01-01", thru::String=string(Dates.today()), freq::Char='d')::TS`


*Example*

```
julia> yahoo("AAPL", from="2010-06-09", thru=string(Dates.today()), freq='w')
356x6 Temporal.TS{Float64,Date}: 2010-06-09 to 2017-03-27
Index       Open    High    Low     Close   Volume      AdjClose  
2010-06-09  251.47  253.86  242.2   253.51  1.813954e8  32.8446   
2010-06-14  255.96  275.0   254.01  274.07  1.814594e8  35.5084   
2010-06-21  277.69  279.01  265.81  266.7   1.763214e8  34.5535   
2010-06-28  266.93  269.75  243.2   246.94  2.087241e8  31.9934   
2010-07-06  251.0   262.9   246.16  259.62  1.525786e8  33.6362   
⋮
2017-02-27  137.14  140.28  136.28  139.78  2.54267e7   139.78    
2017-03-06  139.37  139.98  137.05  139.14  1.97315e7   139.14    
2017-03-13  138.85  141.02  138.82  139.99  2.41057e7   139.99    
2017-03-20  140.4   142.8   139.73  140.64  2.54857e7   140.64    
2017-03-27  139.39  144.49  138.62  144.12  2.86449e7   144.12
```
""" ->
function yahoo(symb::String;
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::Char='d')::TS
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

@doc doc"""
Download stock price data from Yahoo! Finance into a TS object.

`yahoo(syms::Vector{String}; from::String="1900-01-01", thru::String=string(Dates.today()), freq::Char='d')::Dict{String,TS}`
""" ->
function yahoo(syms::Vector{String};
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::Char='d')::Dict{String,TS}
    out = Dict()
    for s = syms
        out[s] = yahoo(s, from=from, thru=thru, freq=freq)
    end
    return out
end
