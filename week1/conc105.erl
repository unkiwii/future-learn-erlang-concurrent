-module(conc105).
-export([server/1]).

server(Pid) ->
  receive
    {check, String} ->
      Pid ! {result, result(String)},
      server(Pid);
    stop ->
      stop
  end.

result(String) ->
  case (is_palindrome(String)) of
    true -> message(String, "");
    false -> message(String, " not")
  end.

message(String, Extra) ->
  unicode:characters_to_list(["\"", String, "\" is", Extra, " a palindrome"]).

is_punctuation(Character) ->
  not(lists:member(Character,"\"\'\t\n ")).

remove_punctuation(String) ->
  lists:filter(fun is_punctuation/1, String).

character_to_lowercase(Character) ->
  case ($A =< Character andalso Character =< $Z) of
    true -> Character + 32;
    false -> Character
  end.

string_to_lowercase(String) ->
  lists:map(fun character_to_lowercase/1, String).

is_palindrome(String) ->
  Normalized = string_to_lowercase(remove_punctuation(String)),
  lists:reverse(Normalized) == Normalized.
