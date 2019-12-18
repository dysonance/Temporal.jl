const YAHOO_URL = "https://query1.finance.yahoo.com/v7/finance/download"  # for querying yahoo's servers
const YAHOO_TMP = "https://ca.finance.yahoo.com/quote/^GSPC/history?p=^GSPC"  # for getting the cookies and crumbs

import HTTP
import Dates


function yahoo_get_crumb()::Tuple{SubString{String}, Dict{String, Set{HTTP.Cookies.Cookie}}}
    response = HTTP.request("GET", YAHOO_TMP)
    m = match(r"\"user\":{\"crumb\":\"(.*?)\"", String(response.body)).captures[1]
    h = response.headers
    # manually grab and parse the cookie
    function substring_after_equal(str;offset::Int64=1)
        idx = collect(findfirst("=",str))[1]
        return String(str[idx+offset:end])
    end
    function return_cookie_string(head)
        for x in head
            if occursin("cookie",lowercase(x[1]))
                return String(x[2])
            end
        end
        return nothing
    end
    cookie_str = return_cookie_string(h)
    split_h = split(cookie_str,";")
    n = String(split_h[1][1:1])
    v = String(split_h[1][3:end])
    expire = substring_after_equal(split_h[2])
    pth = substring_after_equal(split_h[3])
    dom = substring_after_equal(split_h[4],offset=2)
    c = HTTP.Cookies.Cookie(n,v,domain=dom,path=pth,expires=DateTime(expire,"e, d-u-y H:M:S G\\MT"),unparsed=[cookie_str])
    c_dict = (m,Dict(m=>Set([c])))
    return c_dict
end

"""
Download stock price data from Yahoo! Finance into a TS object.

`yahoo(symb::String; from::String="1900-01-01", thru::String=string(Dates.today()), freq::String="d", event::String="history", crumb_tuple::Tuple{SubString{String}, Dict{String, HTTP.Cookie}}=yahoo_get_crumb())::TS`

# Arguments
- `symb` ticker symbol of the stock
- `from` starting date of the historical data request (string formatted as yyyy-mm-dd)
- `thru` ending date of the historical data request (string formatted as yyyy-mm-dd)
- `freq` frequency interval of the requested dowload (valid options are \"d\" for daily, \"wk\" for weekly, and \"mo\" for monthly)
- `event` type of data download to request (valid options are \"history\" for standard historical price data, \"div\" for dividend payments, and \"split\" for stock splits)
- `crumb_tuple` workaround to provide crumbs/cookies for the new Yahoo Finance portal (which requires such data to fulfill the requests)

# Example

```
julia> yahoo("AAPL", from="2010-06-09", thru=string(Dates.today()), freq="wk")
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
"""
function yahoo(symb::String;
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::String="d",
               event::String="history",
               crumb_tuple::Tuple{SubString{String}, Dict{String, Set{HTTP.Cookies.Cookie}}}=yahoo_get_crumb())::TS
    @assert freq in ["d","wk","mo"] "Argument `freq` must be either \"d\" (daily), \"wk\" (weekly), or \"mo\" (monthly)."
    @assert event in ["history","div","split"] "Argument `event` must be either \"history\", \"div\", or \"split\"."
    @assert from[5] == '-' && from[8] == '-' "Argument `from` has invalid date format."
    @assert thru[5] == '-' && thru[8] == '-' "Argument `thru` has invalid date format."
    period1 = Int(floor(Dates.datetime2unix(Dates.DateTime(from))))
    period2 = Int(floor(Dates.datetime2unix(Dates.DateTime(thru))))
    urlstr = "$(YAHOO_URL)/$(symb)?period1=$(period1)&period2=$(period2)&interval=1$(freq)&events=$(event)&crumb=$(crumb_tuple[1])"
    response = HTTP.request("POST",HTTP.URIs.URI(urlstr), cookies=true, cookiejar=crumb_tuple[2])
    indata = Temporal.csvresp(response)
    data = TS(indata[1], indata[2], indata[3][2:end])
    rename!(data, Symbol("Adj Close")=>:AdjClose)
    return data
end

function yahoo(syms::Vector{String};
               from::String="1900-01-01",
               thru::String=string(Dates.today()),
               freq::String="d",
               event::String="history",
               crumb_tuple::Tuple{SubString{String}, Dict{String, HTTP.Cookie}}=yahoo_get_crumb())::Dict{String,TS}
    out = Dict()
    @inbounds for s = syms
        out[s] .= yahoo(s, from=from, thru=thru, freq=freq, event=event, crumb_tuple=crumb_tuple)
    end
    return out
end
