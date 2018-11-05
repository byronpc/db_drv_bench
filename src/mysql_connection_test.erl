-module(mysql_connection_test).

 % CREATE TABLE IF NOT EXISTS `users`
 %     (`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 %      `name` VARCHAR(100) NOT NULL, PRIMARY KEY (`id`)) ENGINE = InnoDB

-define(QUERY, <<"SELECT id FROM users WHERE id = ?">>).

-export([
  bench/2,
  bench/3
]).

bench(Number, Concurrency) ->
  bench(Number, Concurrency, false).

bench(Number, Concurrency, Profile) ->

  {ok, Pools} = mysql_utils:env(pools),
  MyPool = mysql_utils:lookup(mypool, Pools),
  ConnectionOptions = mysql_utils:lookup(connection_options, MyPool),

  ConnFun = fun(_) ->
    {ok, Pid} = mysql_connection:start_link(ConnectionOptions),
    {ok, _} = mysql_connection:prepare(Pid, get_accounts, ?QUERY),
    Pid
  end,

  OpFun = fun(ConnectionPid) ->
    {ok, _, _} = mysql_connection:execute(ConnectionPid, get_accounts, [1])
  end,

  bench:bench(Number, Concurrency, Profile, ConnFun, OpFun).