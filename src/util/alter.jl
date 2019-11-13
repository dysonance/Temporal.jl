# utilities for altering existing TS objects

# in place
function rename!(ts::TS, args::Pair{Symbol, Symbol}...)
    d = Dict{Symbol, Symbol}(args...)
    flag = false
    for (i, field) in enumerate(ts.fields)
        if field in keys(d)
            ts.fields[i] = d[field]
            flag = true
        end
    end
end

function rename!(f::Base.Callable, ts::TS, colnametyp::Type{Symbol} = Symbol)
    for (i, field) in enumerate(ts.fields)
        ts.fields[i] = f(field)
    end
end

function rename!(f::Base.Callable, ts::TS, colnametyp::Type{String})
    f = Symbol ∘ f ∘ string
    rename!(f, ts)
end

# not in place
function rename(ts::TS, args::Pair{Symbol, Symbol}...)
    ts2 = copy(ts)
    rename!(ts2, args...)
    ts2
end

function rename(f::Base.Callable, ts::TS, colnametyp::Type{Symbol} = Symbol)
    ts2 = copy(ts)
    rename!(f, ts2, colnametyp)
    ts2
end

function rename(f::Base.Callable, ts::TS, colnametyp::Type{String})
    ts2 = copy(ts)
    rename!(f, ts2, colnametyp)
    ts2
end
