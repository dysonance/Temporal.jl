# Methods to more easily handle financial data

# Check for various key financial field names
has_open(x::TS)::Bool = any([occursin(r"(op)"i, String(f)) for f in x.fields])
has_high(x::TS)::Bool = any([occursin(r"(hi)"i, String(f)) for f in x.fields])
has_low(x::TS)::Bool = any([occursin(r"(lo)"i, String(f)) for f in x.fields])
has_volume(x::TS)::Bool = any([occursin(r"(vo)"i, String(f)) for f in x.fields])
function has_close(x::TS; allow_settle::Bool=true, allow_last::Bool=true)::Bool
    columns = String.(x.fields)
    if allow_settle && allow_last
        # return any(occursin.(r"(cl)|(last)|(settle)"i, columns))
        return any([occursin(r"(cl)|(last)|(settle)"i, column) for column in columns])
    end
    if allow_last && !allow_settle
        return any([occursin(r"(cl)|(last)"i, column) for column in columns])
    end
    if allow_settle && !allow_last
        return any([occursin(r"(cl)|(settle)"i, column) for column in columns])
    end
    if !allow_last && !allow_settle
        return any([occursin(r"(cl)"i, column) for column in columns])
    end
    return false
end

# Identify OHLC(V) formats
is_ohlc(x::TS)::Bool = has_open(x) && has_high(x) && has_low(x) && has_close(x)
is_ohlcv(x::TS)::Bool = is_ohlc(x) && has_volume(x)

# Extractor functions
op(x::TS)::TS = x[:,findfirst([occursin(r"(op)"i, String(field)) for field in x.fields])]
hi(x::TS)::TS = x[:,findfirst([occursin(r"(hi)"i, String(field)) for field in x.fields])]
lo(x::TS)::TS = x[:,findfirst([occursin(r"(lo)"i, String(field)) for field in x.fields])]
vo(x::TS)::TS = x[:,findfirst([occursin(r"(vo)"i, String(field)) for field in x.fields])]
function cl(x::TS; use_adj::Bool=true, allow_settle::Bool=true, allow_last::Bool=true)::TS
    columns = String.(x.fields)
    if use_adj
        j = findfirst([occursin(r"(adj((usted)|\s|)+)(cl)?"i, column) for column in columns])
        if !isa(j, Nothing)
            return x[:,j]
        end
    else
        j = findfirst([occursin(r"(?!adj)*(cl(ose|))"i, column) for column in columns])
        if !isa(j, Nothing)
            return x[:,j]
        end
    end
    if allow_settle
        j = findfirst([occursin(r"(settle)"i, column) for column in columns])
        if !isa(j, Nothing)
            return x[:,j]
        end
    end
    if allow_last
        j = findfirst([occursin(r"(last)"i, column) for column in columns])
        if !isa(j, Nothing)
            return x[:,j]
        end
    end
    j = findfirst([occursin(r"(cl)"i, column) for column in columns])
    if !isa(j, Nothing)
        return x[:,j]
    end
    error("No closing prices found.")
end
ohlc(x::TS)::TS = [op(x) hi(x) lo(x) cl(x)]
ohlcv(x::TS)::TS = [op(x) hi(x) lo(x) cl(x) vo(x)]
hlc(x::TS)::TS = [hi(x) lo(x) cl(x)]
hl(x::TS)::TS = [hi(x) lo(x)]
hl2(x::TS)::TS = (hi(x) + lo(x)) * 0.5
hlc3(x::TS; args...)::TS = (hi(x) + lo(x) + cl(x; args...)) / 3
ohlc4(x::TS; args...)::TS = (op(x) + hi(x) + lo(x) + cl(x; args...)) * 0.25
