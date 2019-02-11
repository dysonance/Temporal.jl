const QUANDL_URL = "https://www.quandl.com/api/v3/datasets"  # for querying quandl's servers


"""
Set up Quandl user account authorization. Run once passing your Quandl API key, and it will be saved for future use.

`quandl_auth{T<:String}(key::T="")::String`


*Example*

```
julia> quandl_auth("Your_API_Key")
"Your_API_Key"

julia> quandl_auth()
"Your_API_Key"
```
"""
function quandl_auth(key::T=""; authfile::T=expanduser("~/quandl-auth"))::String where {T<:String}
    if key == ""
        if isfile(authfile)
            key = read(authfile, String)
        end
    else
        f = open(authfile, "w")
        write(f, key)
        close(f)
    end
    return key
end

"""
Download time series data from Quandl as a TS object.
```
quandl(code::String;
       from::String="",
       thru::String="",
       freq::Char='d',
       calc::String="none",
       sort::Char='a',
       rows::Int=0,
       auth::String=quandl_auth())::TS
```


# Example

```
julia> quandl("CHRIS/CME_CL1", from="2010-01-01", thru=string(Dates.today()), freq='a')
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
"""
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
    @assert freq in ['d', 'w', 'm', 'q', 'a'] "Invalid `freq` argument (must be in ['d', 'w', 'm', 'q', 'a'])."
    @assert calc in ["none","diff","rdiff","cumul","normalize"] "Invalid `calc` argument."
    @assert sort  == 'a' || sort == 'd' "Argument `sort` must be either \'a\' or \'d\'."
    if rows != 0 && (from != "" || thru != "")
        error("Cannot specify `rows` and date range (`from` or `thru`).")
    end
    # Format URL ===============================================================
    sort_arg = (sort=='a' ? "asc" : "des")
    freq_arg = (freq=='d' ? "daily" : (freq=='w' ? "weekly" : (freq=='m' ? "monthly" : (freq=='q' ? "quarterly" : (freq=='a' ? "annual" : "")))))
    if rows == 0
        fromstr = from == "" ? "" : "&start_date=$from"
        thrustr = thru == "" ? "" : "&end_date=$thru"
        url = "$QUANDL_URL/$code.csv?$(fromstr)$(thrustr)&order=$sort_arg&collapse=$freq_arg&transform=$calc&api_key=$auth"
    else
        url = "$QUANDL_URL/$code.csv?&rows=$rows&order=$sort_arg&collapse=$freq_arg&transform=$calc&api_key=$auth"
    end
    indata = csvresp(HTTP.get(url), sort=sort)
    return TS(indata[1], indata[2], indata[3][2:end])
end

"""
Download Quandl metadata for a database and dataset into a Julia Dict object.

`quandl_meta(database::String, dataset::String)`
"""
function quandl_meta(database::String, dataset::String)::Dict{String,Any}
    resp = HTTP.get("$QUANDL_URL/$database/$dataset/metadata.json")
    @assert resp.status == 200 "Error downloading metadata from Quandl."
    return JSON.parse(String(resp.body))["dataset"]
end

"""
Search Quandl for data in a given database, `db`, or matching a given query, `qry`.

`quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)`
"""
function quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)
    @assert db!="" || qry!="" "Must enter a database or a search query."
    dbstr = db   == "" ? "" : "database_code=$db&"
    qrystr = qry  == "" ? "" : "query=$(replace(qry, ' ', '+'))&"
    resp = HTTP.get("$QUANDL_URL.json?$(dbstr)$(qrystr)per_page=$perpage&page=$pagenum")
    @assert resp.status == 200 "Error retrieving search results from Quandl"
    return JSON.parse(String(resp.body))
end
