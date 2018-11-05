-module(pgapp_test).

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

  ConnFun = fun(_) -> ok end,

  OpFun = fun(_) ->
    pgapp:equery(pgpool, ?QUERY, [1])
  end,

  bench:bench(Number, Concurrency, Profile, ConnFun, OpFun).