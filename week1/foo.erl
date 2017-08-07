-module(foo).
-export([bar/0, bar/1, recv/0, recv_stop/0]).

bar() ->
  timer:sleep(1000),
  io:format("one second passed~n"),
  timer:sleep(1000),
  io:format("two seconds passed~n"),
  timer:sleep(1000),
  io:format("three second passed~n"),
  io:format("bye~n").

bar(Pid) ->
  timer:sleep(1000),
  Pid ! "one second passed~n",
  timer:sleep(1000),
  Pid ! "two seconds passed~n",
  timer:sleep(1000),
  Pid ! "three second passed~n",
  io:format("bye~n").

recv() ->
  receive
    Msg ->
      io:format("received ~p~n", [Msg]),
      recv()
  end.

recv_stop() ->
  receive
    stop ->
      io:format("stopping~n");
    Msg ->
      io:format("received ~p~n", [Msg]),
      recv_stop()
  end.
