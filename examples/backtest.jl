# load dependencies
using Temporal, Indicators, Base.Dates

# define backtest setup
from_date = today() - Year(10)
thru_date = today()
trade_qty = 10.0
initial_balance = 1e6
trade_field = :Open
close_field = :Settle

# define indicator parameters
ind_fun = Indicators.mama
ind_vals(x::TS) = hl2(x)
ind_args = (:fastlimit, 0.5,
            :slowlimit, 0.05)
ind_args_rng = (:fastlimit, 0.01:0.01:0.99,
                :slowlimit, 0.01:0.01:0.99)

# download historical data
X = quandl("CHRIS/CME_CL1", from=string(from_date), thru=string(thru_date))
ind_out = ind_fun(ind_vals(X); ind_args)

# initialize backtest variables
N = size(X,1)
go_long = crossover(ind_out[:MAMA].values, ind_out[:FAMA].values)
go_short = crossunder(ind_out[:MAMA].values, ind_out[:FAMA].values)
pnl = zeros(Float64, N)
pos = zeros(Float64, N)
in_price = NaN
trade_price = X[:,trade_field].values
close_price = X[:,close_field].values

# run trading logic for base case (default indicator args)
@inbounds for i in 2:N
    if go_long[i-1]
        pos[i] = trade_qty
        pnl[i] = pos[i] * (close_price[i] - trade_price[i])
    elseif go_short[i-1]
        pos[i] = -trade_qty
        pnl[i] = pos[i] * (close_price[i] - trade_price[i])
    else
        pos[i] = pos[i-1]
        pnl[i] = pos[i] * (close_price[i]-close_price[i-1])
    end
end
# summarize results from backtest
summary_ts = TS([Temporal.ohlc(X).values ind_out.values go_long go_short pos pnl cumsum(pnl)],
                X.index,
                vcat(Temporal.ohlc(X).fields, [:MAMA, :FAMA, :LongSignal, :ShortSignal, :Position, :PNL, :CumulativePNL]))

# visualize backtest results
using Plots
ℓ = @layout [ a; b{0.33h} ]
plotlyjs()
plot(
     plot(summary_ts[:,vcat(close_field,ind_out.fields)], color=[:black :magenta :green]),
     plot(summary_ts[:,end], color=:orange, fill=(0,:orange), fillalpha=0.5),
     layout = ℓ
)

# run trading logic for range of indicator arguments and store cumulative pnl
# get summary information about the variables to simplify the run later on
n_runs = 1
n_args = round(Int, length(ind_args_rng)/2)
rng_lens = ones(Int, n_args)
arg_syms = Vector{Symbol}(n_args)
arg_rngs = Vector{Any}(n_args)
@inbounds for arg_i in 1:n_args
    rng_lens[arg_i] = length(ind_args_rng[arg_i*2])
    arg_syms[arg_i] = ind_args_rng[arg_i*2-1]
    arg_rngs[arg_i] = ind_args_rng[arg_i*2]
end
n_runs = prod(rng_lens)
cum_pnl = zeros(Float64, n_runs)

#TODO: try this using a dict that gets updated at each run?
arg_dict = Dict{Symbol,Any}()
arg_dict[:fastlimit] = 0.5
arg_dict[:slowlimit] = 0.05
#FIXME: use call like this (note semicolon and dots): mama(hl2(X); arg_dict...)
mama(hl2(X); arg_dict...)

#arg_pairs = zeros(n_runs, n_args)
#arg_pairs[:,1] = repmat(arg_rngs[1], round(Int, n_runs/rng_lens[1]))
#rows = 1:99
#for i in 1:rng_lens[2]
#    println(i)
#    arg_pairs[rows,2] = repmat([arg_rngs[2][i]], rng_lens[2])
#    rows += rng_lens[2]
#end

# # next, initialize a vector of the indicator argument tuples
# arg_pairs = Vector{typeof(ind_args)}(n_runs)
# # must assign first so that can edit specific parts of the tuples
# @inbounds for i in 1:n_runs
#     arg_pairs[i] = ind_args
#     @inbounds for j in 1:n_args
#         arg_pairs[i][j*2-1] = arg_syms
#         @inbounds for k in 1:rng_lens[j]
#             arg_pairs[i][j*2] = ind_args_rng[j*2][k]
#         end
#     end
# end

