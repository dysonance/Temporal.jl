const QUANDL_URL = "https://www.quandl.com/api/v3/datasets"  # for querying quandl's servers

import JSON
import HTTP


"""
Set up Quandl user account authorization. Run once passing your Quandl API key, and it will be saved for future use.


    quandl_auth(key::String=""; authfile::String=joinpath(homedir(),"quandl-auth"))::String

"""
function quandl_auth(key::String=""; authfile::String=joinpath(homedir(),"quandl-auth"))::String
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

# Arguments

- `code::String;`: quandl code to query
- `from::String=""`: start date from which the data should begin, expressed as a string of format yyyy-mm-dd
- `thru::String=""`: end date through which the data should continue, expressed as a string of format yyyy-mm-dd
- `freq::Char='d'`: frequency at which the data should occur (one of 'd', 'w', 'm', 'q', or 'a')
- `calc::String="none"`: the calculation passed through to the Quandl engine (one of "none", "diff", "rdiff", "cumul", or "normalize")
- `sort::Char='a'`: direction in which to sort results (one of 'a' or 'd')
- `rows::Int=0`: number of rows to return from query (default corresponds to all rows)
- `auth::String=quandl_auth()`: authorization token for the Quandl API dedicated to a user account

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
    indata = Temporal.csvresp(HTTP.get(url), sort=sort)
    return TS(indata[1], indata[2], indata[3][2:end])
end

"""
Download Quandl metadata for a database and dataset into a Julia Dict object.

    quandl_meta(database::String, dataset::String)::Dict{String,Any}

"""
function quandl_meta(database::String, dataset::String)::Dict{String,Any}
    resp = HTTP.get("$QUANDL_URL/$database/$dataset/metadata.json")
    @assert resp.status == 200 "Error downloading metadata from Quandl."
    return JSON.parse(String(resp.body))["dataset"]
end

"""
Search Quandl for data in a given database, `db`, or matching a given query, `qry`.

    quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)

"""
function quandl_search(;db::String="", qry::String="", perpage::Int=1, pagenum::Int=1)
    @assert db!="" || qry!="" "Must enter a database or a search query."
    dbstr = db   == "" ? "" : "database_code=$db&"
    qrystr = qry  == "" ? "" : "query=$(replace(qry, ' ' => '+'))&"
    resp = HTTP.get("$QUANDL_URL.json?$(dbstr)$(qrystr)per_page=$perpage&page=$pagenum")
    @assert resp.status == 200 "Error retrieving search results from Quandl"
    return JSON.parse(String(resp.body))
end
