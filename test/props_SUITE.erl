%% @doc props tests.
-module(props_SUITE).

-export([all/0,
         basic_get_with_atom_path/1,
         array_get_with_atom_path/1,
         basic_get_with_string_path/1,
         array_get_with_string_path/1,
         simple_get/1,
         simple_set/1,
         multi_set/1,
         array_index_change/1,
         create_implicit_props/1,
         create_implicit_array/1,
         create_implicit_index/1,
         throw_on_get_non_props/1,
         throw_on_get_non_array/1,
         throw_on_set_non_props/1,
         throw_on_set_non_array/1,
         throw_on_set_array_oob/1]).

-include_lib("common_test/include/ct.hrl").

-define(DATA, {[{<<"a">>, 1},
                {<<"b">>, [2, {[{<<"c">>, 3}]}]},
                {<<"d">>, {[{<<"e">>, {[{<<"f">>, 4}]}}]}}]}).

-define(assertThrows(Exc, Expr),
        begin
            try
                Expr,
                throw(no_throw)
            catch
                throw:no_throw ->
                    ct:fail(no_throw);
                throw:Exception___ ->
                    case Exception___ of
                        Exc -> ok;
                        _ -> ct:fail({wrong_throw, throw, Exception___})
                    end;
                Class___:Exception___ ->
                    ct:fail({wrong_throw, Class___, Exception___})
            end
        end).

all() ->
    [basic_get_with_atom_path,
     array_get_with_atom_path,
     basic_get_with_string_path,
     array_get_with_string_path,
     simple_get,
     simple_set,
     multi_set,
     array_index_change,
     create_implicit_props,
     create_implicit_array,
     create_implicit_index,
     throw_on_get_non_props,
     throw_on_get_non_array,
     throw_on_set_non_props,
     throw_on_set_non_array,
     throw_on_set_array_oob].

%% Basic get tests.

basic_get_with_atom_path(_Config) ->
    4 = props:get(d.e.f, ?DATA).

array_get_with_atom_path(_Config) ->
    3 = props:get('b[2].c', ?DATA).

basic_get_with_string_path(_Config) ->
    4 = props:get("d.e.f", ?DATA).

array_get_with_string_path(_Config) ->
    3 = props:get("b[2].c", ?DATA).

simple_get(_Config) ->
    1 = props:get(a, ?DATA).

simple_set(_Config) ->
    {[{<<"a">>, 1}]} = props:set(a, 1, props:new()).

multi_set(_Config) ->
    Src = {[{<<"a">>, {[{<<"b">>, {[]}}]}},
            {<<"b">>, 2}]},
    Dst = {[{<<"a">>, {[{<<"b">>, {[{<<"c">>, 1}]}}]}},
            {<<"b">>, 2}]},
    Dst = props:set(a.b.c, 1, Src).

array_index_change(_Config) ->
    Src = {[{<<"a">>, [1]}]},
    Dst = {[{<<"a">>, [2]}]},
    Dst = props:set("a[1]", 2, Src).

create_implicit_props(_Config) ->
    Src = {[]},
    Dst = {[{<<"a">>, {[{<<"b">>, 1}]}}]},
    Dst = props:set(a.b, 1, Src).

create_implicit_array(_Config) ->
    Src = {[]},
    Dst = {[{<<"a">>, [1]}]},
    Dst = props:set("a[1]", 1, Src).

create_implicit_index(_Config) ->
    Src = {[{<<"a">>, [1,2,3]}]},
    Dst = {[{<<"a">>, [1,2,3,4]}]},
    Dst = props:set("a[4]", 4, Src).

throw_on_get_non_props(_Config) ->
    ?assertThrows({error, {invalid_access, key, _, _}},
                  props:get(a.b, ?DATA)).

throw_on_get_non_array(_Config) ->
    ?assertThrows({error, {invalid_access, index, _, _}},
                  props:get("d[1]", ?DATA)).

throw_on_set_non_props(_Config) ->
    ?assertThrows({error, {invalid_access, key, _, _}},
                  props:set(a.b, 1, ?DATA)).

throw_on_set_non_array(_Config) ->
    ?assertThrows({error, {invalid_access, index, _, _}},
                  props:set("a[1]", 1, ?DATA)).
    
throw_on_set_array_oob(_Config) ->
    ?assertThrows({error, {invalid_access, index, _, _}},
                  props:set("a[5]", 1, {[{<<"a">>, [1,2,3]}]})).