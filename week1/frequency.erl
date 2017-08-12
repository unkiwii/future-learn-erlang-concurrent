-module(frequency).
-export([start/0, allocate/0, deallocate/1, stop/0, clear/0]).
-export([init/0]).

start() ->
  register(frequency, spawn(frequency, init, [])).

clear() ->
  frequency ! {request, self(), clear},
  receive
    {reply, Reply} -> Reply
  end.

allocate() ->
  frequency ! {request, self(), allocate},
  receive
    {reply, Reply} -> Reply
  after 1000 ->
    clear(),
    {error, allocate_timeout}
  end.

deallocate(Freq) ->
  frequency ! {request, self(), {deallocate, Freq}},
  receive
    {reply, Reply} -> Reply
  after 1000 ->
    clear(),
    {error, deallocate_timeout}
  end.

stop() ->
  clear(),
  frequency ! {request, self(), stop},
  receive
    {reply, Reply} -> Reply
  end.

%% internal helper functions

init() ->
  Frequencies = {get_frequencies(), []},
  loop(Frequencies).

get_frequencies() -> [10,11,12,13,14,15].

loop(Frequencies) ->
  receive
    {request, Pid, allocate} ->
      {NewFrequencies, Reply} = allocate(Frequencies, Pid),
      Pid ! {reply, Reply},
      loop(NewFrequencies);
    {request, Pid , {deallocate, Freq}} ->
      NewFrequencies = deallocate(Frequencies, Freq),
      Pid ! {reply, ok},
      loop(NewFrequencies);
    {request, Pid, clear} ->
      clear_mailbox(),
      Pid ! {reply, cleared},
      loop(Frequencies);
    {request, Pid, stop} ->
      Pid ! {reply, stopped}
  after 1000 ->
    clear_mailbox(),
    loop(Frequencies)
  end.

clear_mailbox() ->
  receive
    M ->
      io:format("clearing ~w~n", [M]),
      clear_mailbox()
  after 0 ->
    ok
  end.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  case lists:keymember(Pid, 2, Allocated) of
    true ->
      {{[Freq|Free], Allocated}, {error, already_allocated}};
    _ ->
      {{Free, [{Freq, Pid}|Allocated]}, {ok, Freq}}
  end.

deallocate({Free, Allocated}, Freq) ->
  case lists:keymember(Freq, 1, Allocated) of
    true ->
      NewAllocated=lists:keydelete(Freq, 1, Allocated),
      {[Freq|Free],  NewAllocated};
    _ ->
      {Free, Allocated}
  end.
