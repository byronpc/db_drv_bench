-module(epgsql_test).

% CREATE TABLE users(id serial PRIMARY KEY, name VARCHAR(100));

-define(QUERY, <<"SELECT id FROM users WHERE id = $1">>).

-export([
    bench/2,
    bench/3
]).

bench(Number, Concurrency) ->
    bench(Number, Concurrency, false).

bench(Number, Concurrency, Profile) ->

    Self = self(),
    LoopNumbers = Number div Concurrency,

    ConnectionOptions = bench_connection_options(),
    List = lists:map(fun(_) ->
        bench_connection(ConnectionOptions)
    end, lists:seq(1, Concurrency)),

    BenchFun = fun(Pid) ->
        bench_connection_loop(LoopNumbers, Pid)
    end,

    profilers_start(Profile),
    A = os:timestamp(),
    Pids = [spawn_link(fun() -> BenchFun(X), Self ! {self(), done} end) || X <- List],
    [receive {Pid, done} -> ok end || Pid <- Pids],
    B = os:timestamp(),
    profiler_stop(Profile),

    print(Number, A, B).

bench_connection(ConnectionOptions) ->
    {ok, Pid} = epgsql:connect(ConnectionOptions),
    {ok, _} = epgsql:parse(Pid, <<"get_accounts">>, ?QUERY, []),
    Pid.

bench_connection_options() ->
    application:get_all_env(epgsql).

bench_connection_loop(0, _ConnectionPid) ->
    ok;
bench_connection_loop(Nr, ConnectionPid) ->
    {ok,_,_} = epgsql:prepared_query(ConnectionPid, <<"get_accounts">>, [1]),
    bench_connection_loop(Nr-1, ConnectionPid).

print(Num, A, B) ->
    Microsecs = timer:now_diff(B, A),
    Time = Microsecs div Num,
    PerSec = case Time of
         0 ->
             "N/A";
         _ ->
             1000000 div Time
    end,

    io:format("### ~p ms ~p req/sec ~n", [Microsecs div 1000, PerSec]).

loop(0, _Fun) ->
    ok;
loop(Nr, Fun) ->
    Fun(),
    loop(Nr-1, Fun).

profilers_start(true)->
    {ok, P} = eprof:start(),
    eprof:start_profiling(processes() -- [P]);
profilers_start(_)->
    ok.

profiler_stop(true)->
    eprof:stop_profiling(),
    eprof:analyze(total),
    eprof:stop();
profiler_stop(_)->
    ok.
