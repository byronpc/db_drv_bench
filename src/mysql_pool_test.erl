-module(mysql_pool_test).

 % CREATE TABLE IF NOT EXISTS `users`
 %     (`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 %      `name` VARCHAR(100) NOT NULL, PRIMARY KEY (`id`)) ENGINE = InnoDB

-define(QUERY, <<"SELECT id FROM users WHERE id = ?">>).

-export([
  bench/2,
  bench/4
]).

bench(Number, Concurrency) ->
  bench(Number, Concurrency, pool, false).

bench(Number, Concurrency, Mode, Profile) ->
  ok = mysql_pool:prepare(mypool, get_accounts, ?QUERY),

  ConnFun = fun(_) -> ok end,

  OpFun = fun(_) ->
    {ok, _, _} = mysql_pool:execute(mypool, get_accounts, [1])
  end,

  bench:bench(Number, Concurrency, Profile, ConnFun, OpFun).