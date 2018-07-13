# Methods to more easily handle financial data

# Check for various key financial field names
has_open(x::TS)::Bool = any(ismatch.(r"(op)"i, String.(x.fields)))
has_high(x::TS)::Bool = any(ismatch.(r"(hi)"i, String.(x.fields)))
has_low(x::TS)::Bool = any(ismatch.(r"(lo)"i, String.(x.fields)))
has_volume(x::TS)::Bool = any(ismatch.(r"(vo)"i, String.(x.fields)))
function has_close(x::TS; allow_settle::Bool=true, allow_last::Bool=true)::Bool
    columns = String.(x.fields)
    if allow_settle && allow_last
        return any(ismatch.(r"(cl)|(last)|(settle)"i, columns))
    end
    if allow_last && !allow_settle
        return any(ismatch.(r"(cl)|(last)"i, columns))
    end
    if allow_settle && !allow_last
        return any(ismatch.(r"(cl)|(settle)"i, columns))
    end
    if !allow_last && !allow_settle
        return any(ismatch.(r"(cl)"i, columns))
    end
    return false
end

# Identify OHLC(V) formats
is_ohlc(x::TS)::Bool = has_open(x) && has_high(x) && has_low(x) && has_close(x)
is_ohlcv(x::TS)::Bool = is_ohlc(x) && has_volume(x)

# Extractor functions
op(x::TS)::TS = x[:,findfirst(ismatch.(r"(op)"i, String.(x.fields)))]
hi(x::TS)::TS = x[:,findfirst(ismatch.(r"(hi)"i, String.(x.fields)))]
lo(x::TS)::TS = x[:,findfirst(ismatch.(r"(lo)"i, String.(x.fields)))]
vo(x::TS)::TS = x[:,findfirst(ismatch.(r"(vo)"i, String.(x.fields)))]
function cl(x::TS; use_adj::Bool=true, allow_settle::Bool=true, allow_last::Bool=true)::TS
    columns = String.(x.fields)
    if use_adj
        j = findfirst(ismatch.(r"(adj((usted)|\s|)+)?(cl)"i, columns))
        if j != 0
            return x[:,j]
        end
    else
        j = findfirst(ismatch.(r"^((?!adj).)*(cl(ose|))"i, columns))
        if j != 0
            return x[:,j]
        end
    end
    if allow_settle
        j = findfirst(ismatch.(r"(settle)"i, columns))
        if j != 0
            return x[:,j]
        end
    end
    if allow_last
        j = findfirst(ismatch.(r"(last)"i, columns))
        if j != 0
            return x[:,j]
        end
    end
    error("No closing prices found.")
end
ohlc(x::TS)::TS = [op(x) hi(x) lo(x) cl(x)]
ohlcv(x::TS)::TS = [op(x) hi(x) lo(x) cl(x) vo(x)]
hlc(x::TS)::TS = [hi(x) lo(x) cl(x)]
hl(x::TS)::TS = [hi(x) lo(x)]
hl2(x::TS)::TS = (hi(x) + lo(x)) * 0.5
hlc3(x::TS; args...)::TS = (hi(x) + lo(x) + cl(x; args...)) * 0.3333333333333333
ohlc4(x::TS; args...)::TS = (op(x) + hi(x) + lo(x) + cl(x; args...)) * 0.25
