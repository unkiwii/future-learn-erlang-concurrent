-module(conc108).
-export([receiver1/0, receiver2/0, receiver3/0, receiver4/0, ordered/0]).

receiver1() ->
  receive
    stop ->
      io:format("stopping receiver1~n");
    Msg ->
      io:format("message1:~w~n", [Msg]),
      receiver1()
  end.

receiver2() ->
  time:sleep(1000),
  receive
    stop ->
      io:format("stopping receiver2~n");
    Msg ->
      io:format("message2:~w~n", [Msg]),
      receiver2()
  end.

receiver3() ->
  receive
    Msg ->
      case Msg of
        stop ->
          io:format("stopping receiver3~n");
        X ->
          io:format("message3:~w~n", [X]),
          receiver3()
      end
  end.

receiver4() ->
  time:sleep(1000),
  receive
    Msg ->
      case Msg of
        stop ->
          io:format("stopping receiver4~n");
        X ->
          io:format("message4:~w~n", [X]),
          receiver4()
      end
  end.

ordered() ->
  ordered([first, second]).

ordered([]) ->
  receive
    stop ->
      io:format("stopping ordered~n")
  end;
ordered([X|Xs]) ->
  receive
    {X, N} ->
      io:format("got {~w, ~w}~n", [X, N]),
      ordered(Xs)
  end.
