const GOOGLE_URL = "http://finance.google.com/finance/historical?"  # for querying google finance's servers

import Printf: @sprintf
import HTTP


"""
Download stock price data from Google Finance into a TS object.

`google(symb::String; from::String="2000-01-01", thru::String=string(Dates.today()))::TS`

# Arguments
- `symb` ticker symbol of the stock
- `from` starting date of the historical data request (string formatted as yyyy-mm-dd)
- `thru` ending date of the historical data request (string formatted as yyyy-mm-dd)

# Example

```
julia> google("IBM", from="2010-06-09", thru=string(Dates.today()))
1756x5 Temporal.TS{Float64,Date}: 2010-06-09 to 2017-05-30
Index       Open    High    Low     Close   Volume
2010-06-09  124.83  125.84  123.58  123.9   7.800309e6
2010-06-10  125.99  128.22  125.8   127.68  7.47961e6
2010-06-11  126.73  128.8   126.44  128.45  5.827093e6
2010-06-14  128.5   129.97  128.49  128.5   6.753113e6
2010-06-15  128.93  129.95  128.37  129.79  6.652612e6
⋮
2017-05-23  152.57  153.68  151.92  152.03  2.564503e6
2017-05-24  152.21  152.76  151.23  152.51  3.732399e6
2017-05-25  153.25  153.73  152.95  153.2   2.582815e6
2017-05-26  152.85  153.0   152.06  152.49  2.443507e6
2017-05-30  151.95  152.67  151.59  151.73  3.666032e6
```
"""
function google(symb::String;
                from::String="2000-01-01",
                thru::String=string(Dates.today()))::TS
    from_date = parse(Date, from, Dates.DateFormat("yyyy-mm-dd"))
    thru_date = parse(Date, thru, Dates.DateFormat("yyyy-mm-dd"))
    url = string("$(GOOGLE_URL)q=$(symb)",
                 "&startdate=$(Dates.monthabbr(Dates.month(from_date)))",
                 "+$(@sprintf("%.2d",Dates.dayofmonth(from_date)))",
                 "+$(Dates.year(from_date))",
                 "&enddate=$(Dates.monthabbr(thru_date))",
                 "+$(@sprintf("%.2d",Dates.dayofmonth(thru_date)))",
                 "+$(Dates.year(thru_date))&output=csv")
    response = HTTP.get(url)
    indata = Temporal.csvresp(response)
    return TS(indata[1], indata[2], indata[3][2:end])
end
