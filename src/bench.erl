-module(bench).
-export([bench/5]).

bench(Number, Concurrency, Profile, ConnFun, OpFun) ->

  Self = self(),
  LoopNumbers = Number div Concurrency,

  List = lists:map(ConnFun, lists:seq(1, Concurrency)),

  BenchFun = fun(Pid) ->
    bench_connection_loop(LoopNumbers, Pid, OpFun)
  end,

  profilers_start(Profile),
  A = os:timestamp(),
  Pids = [spawn_link(fun() -> BenchFun(X), Self ! {self(), done} end) || X <- List],
  [receive {Pid, done} -> ok end || Pid <- Pids],
  B = os:timestamp(),
  profiler_stop(Profile),
  print(Number, A, B).

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

bench_connection_loop(0, _ConnectionPid, _OpFun) ->
    ok;
bench_connection_loop(Nr, ConnectionPid, OpFun) ->
  OpFun(ConnectionPid),
  bench_connection_loop(Nr-1, ConnectionPid, OpFun).