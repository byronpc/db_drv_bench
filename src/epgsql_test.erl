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

  ConnectionOptions = application:get_all_env(epgsql),

  ConnFun = fun(_) ->
    {ok, Pid} = epgsql:connect(ConnectionOptions),
    {ok, _} = epgsql:parse(Pid, <<"get_accounts">>, ?QUERY, []),
    Pid
  end,

  OpFun = fun(ConnectionPid) ->
    {ok,_,_} = epgsql:prepared_query(ConnectionPid, <<"get_accounts">>, [1])
  end,

  bench:bench(Number, Concurrency, Profile, ConnFun, OpFun).