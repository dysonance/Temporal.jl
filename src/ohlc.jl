# Methods to more easily handle financial data
import Base.close

# Check for various key financial field names
has_open(x::TS)::Bool = any(x.fields .== :Open)
has_high(x::TS)::Bool = any(x.fields .== :High)
has_low(x::TS)::Bool = any(x.fields .== :Low)
has_volume(x::TS)::Bool = any(x.fields .== :Volume)
function has_close(x::TS; allow_settle::Bool=true, allow_last::Bool=true)::Bool
    if any(x.fields .== :Close)
        return true
    end
    if allow_settle && any(x.fields .== :Settle)
        return true
    end
    if allow_last && any(x.fields .== :Last)
        return true
    end
    return false
end

# Identify OHLC(V) formats
is_ohlc(x::TS)::Bool = has_open(x) && has_high(x) && has_low(x) && has_close(x)
is_ohlcv(x::TS)::Bool = is_ohlc(x) && has_volume(x)

# Extractor functions
open(x::TS)::TS = x[:,:Open]
high(x::TS)::TS = x[:,:High]
low(x::TS)::TS = x[:,:Low]
volume(x::TS)::TS = x[:,:Volume]
function close(x::TS; use_adj::Bool=true, allow_settle::Bool=true, allow_last::Bool=true)::TS
    if use_adj
        out = x[:AdjClose]
    end
    if !use_adj || size(out,2) == 0
        out = x[:,:Close]
    end
    if size(out,2) > 0
        return out
    end
    if allow_settle
        out = x[:,:Settle]
        if size(out,2) > 0
            return out
        end
    end
    if allow_last
        out = x[:,:Last]
        if size(out,2) > 0
            return out
        end
    end
    return out
end
ohlc(x::TS)::TS = [open(x) high(x) low(x) close(x)]
ohlcv(x::TS)::TS = [open(x) high(x) low(x) close(x) volume(x)]
hlc(x::TS)::TS = [high(x) low(x) close(x)]
hl(x::TS)::TS = [high(x) low(x)]
