%%==============================================================================
%% Copyright 2013 Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%==============================================================================

%%%-------------------------------------------------------------------
%%% @doc
%%%  A lazy lib.
%%%
%%% This library provides a simple pull oriented interface towards different
%%% data sources using a lazy data abstraction.
%%%
%%% The primary use case is the decoding of protocols where the sizes of parts
%%% are not known until they have been completely decoded and one wishes to
%%% decouple the handling of the data source and the protocol code.
%%%
%%% The user of the library provides a promise of data: a function that
%%% given a timeout returns either a data or eol (end of lazy) within
%%% the timespan given by the timeout. A promise can also have a state
%%% in which case the initial state has to be provided with the function.
%%% The stateful promise function must retun a tuple of {Data, NewState}.
%%%
%%% The library provides the functions create/1 and create/2 to create
%%% lazy data structures given a promise. The structure can then be
%%% applied to a timeout to generate a tuple of data and new lazy data
%%% {Data, Lazy} or eol.
%%%
%%% Two functions to add a data to existing lazy data are provided:
%%% prepend/2 and append/2 that adds the data before or after the lazy data
%%% respectively.
%%%
%%% A number of utility funtions are provided, functioning both as simple
%%% examples as well as convenience for basic uses:
%%%   list_to_data/1, iolist_to_data/1
%%%   tcp_to_data/2, tcp_to_data/3,tcp_to_data/4, tcp_socket_to_data/1
%%%   file_to_data/2, file_stream_to_data/2
%%%
%%% N.B. This library relies heavily on the construction of lambda functions
%%%      and for the sake of clearity and efficiency should be avoided if a
%%%      more direct approach, that does not suffer heavily from these very
%%%      drawback itself, exists.
%%% @end
%%%
%% @author Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%% @copyright (C) 2013, Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%%-------------------------------------------------------------------
-module(lazy).
-copyright('Jan Henry Nystrom <JanHenryNystrom@gmail.com>').

%% Library functions
-export([create/1, create/2]).

-export([prepend/2, append/2]).

-export([list_to_data/1, iolist_to_data/1,
         tcp_to_data/2, tcp_to_data/3,tcp_to_data/4, tcp_socket_to_data/1,
         file_to_data/2, file_stream_to_data/2
        ]).

%% Types
-type data(Type) :: fun(([timeout()]) -> {Type, data(Type)}) | eol.

-type promise(Type) :: fun(([timeout()]) -> Type | eol).
-type promise(Type, State) :: fun(([timeout()], State) -> {Type, State} | eol).

%% Exported Types
-export_type([data/1, promise/1, promise/2]).


%% ===================================================================
%% Library functions.
%% ===================================================================

%%--------------------------------------------------------------------
%% Function: create(Promise) -> LazyData
%% @doc
%%   Given a promise, lazy data is created.
%% @end
%%--------------------------------------------------------------------
-spec create(promise(Type)) -> data(Type).
%%--------------------------------------------------------------------
create(F) ->
    fun(Timeout) ->
            case F(Timeout) of
                eol -> eol;
                Data -> {Data, create(F)}
            end
    end.

%%--------------------------------------------------------------------
%% Function: create(Promise, State) -> LazyData
%% @doc
%%   Given a promise and an initial state, stateful lazy data is created.
%% @end
%%--------------------------------------------------------------------
-spec create(promise(Type, State), State) -> data(Type).
%%--------------------------------------------------------------------
create(F, State) ->
    fun(Timeout) ->
            case F(Timeout, State) of
                {Data, State1} -> {Data, create(F, State1)};
                eol -> eol
            end
    end.

%%--------------------------------------------------------------------
%% Function: prepend(Data, LazyData) -> LazyData.
%% @doc
%%   Lazy data is constructed from data and lazy data where when cosumed
%%   the data comes before any of the lazy data.
%% @end
%%--------------------------------------------------------------------
-spec prepend(Type, data(Type)) -> data(Type).
%%--------------------------------------------------------------------
prepend(Data, Lazy) -> fun(_) -> {Data, Lazy} end.

%%--------------------------------------------------------------------
%% Function: append(Data, LazyData) -> LazyData.
%% @doc
%%   Lazy data is constructed from data and lazy data where when cosumed
%%   the data comes after all of the lazy data.
%% @end
%%--------------------------------------------------------------------
-spec append(Type, data(Type)) -> data(Type).
%%--------------------------------------------------------------------
append(Data, Lazy) ->
    fun(Timeout) ->
            case Lazy(Timeout) of
                eol -> {Data, fun(_) -> eol end};
                {Data1, Lazy1} -> {Data1, append(Data, Lazy1)}
            end
    end.

%%--------------------------------------------------------------------
%% Function: list_to_data(DataList) -> LazyData
%% @doc
%%   Lazy data is constructed from a list.
%% @end
%%--------------------------------------------------------------------
-spec list_to_data([Type]) -> data(Type).
%%--------------------------------------------------------------------
list_to_data(List) ->
    Promise = fun(_, []) -> eol;
                 (_, [H | T]) -> {H, T}
              end,
    create(Promise, List).

%%--------------------------------------------------------------------
%% Function: iolist_to_data(IOList) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from an iolist.
%% @end
%%--------------------------------------------------------------------
-spec iolist_to_data(iolist()) -> data(binary()).
%%--------------------------------------------------------------------
iolist_to_data(List) ->
    Promise = fun(_, []) -> eol;
                 (_, [H | T]) when is_binary(H) -> {H, iolist_to_data(T)};
%% TODO should have deep traversal
                 (_, [H | T]) -> {iolist_to_binary(H), iolist_to_data(T)}
              end,
    create(Promise, List).

%%--------------------------------------------------------------------
%% Function: tcp_to_data(Host, Port) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the socket that opening a tcp connetion
%%   to the host in binary mode with packet size 0. If an error occurs during
%%   connection an error is returned.
%% @end
%%--------------------------------------------------------------------
-spec tcp_to_data(HostName, Port) -> data(binary()) | {error, inet:posix()} when
      HostName:: inet:ip_address() | inet:hostname(),
      Port ::inet:port_number().
%%--------------------------------------------------------------------
tcp_to_data(HostName, Port) -> tcp_to_data(HostName, Port, infinity).

%%--------------------------------------------------------------------
%% Function: tcp_to_data(Host, Port, Timeout) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the socket that opening a tcp connetion
%%   to the host in binary mode with packet size 0. If an error or timeout
%%   occurs during connection an error is returned.
%% @end
%%--------------------------------------------------------------------
-spec tcp_to_data(HostName, Port, timeout()) ->
          data(binary()) | {error, inet:posix()} when
      HostName:: inet:ip_address() | inet:hostname(),
      Port ::inet:port_number().
%%--------------------------------------------------------------------
tcp_to_data(HostName, Port, Timeout) -> tcp_to_data(HostName, Port, Timeout,[]).

%%--------------------------------------------------------------------
%% Function: tcp_to_data(Host, Port, Timeout, TCPOptions) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the socket that opening a tcp connetion
%%   to the host in binary mode with packet size 0. If an error or timeout
%%   occurs during connection an error is returned.
%%   If the options provided are inconsistent with:
%%   {packet, 0}, binary, {active, false}
%%   unexpected and undefined behaviour will be the result.
%% @end
%%--------------------------------------------------------------------
-spec tcp_to_data(HostName, Port, timeout(), [gen_tcp:connect_option()]) ->
          data(binary()) | {error, inet:posix()} when
      HostName:: inet:ip_address() | inet:hostname(),
      Port ::inet:port_number().
%%--------------------------------------------------------------------
tcp_to_data(HostName, Port, Timeout, OptionsIn) ->
    Options = [{packet, 0}, binary, {active, false} | OptionsIn],
    case gen_tcp:connect(HostName, Port, Options, Timeout) of
        {ok, Socket} -> tcp_socket_to_data(Socket);
        Error = {error, _}  -> Error
    end.

%%--------------------------------------------------------------------
%% Function: tcp_socket_to_data(Socket) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the socket, it is expected to be
%%   connected to the host in binary mode with packet size 0.
%%   On errors/closure reading from the socket results in the closure
%%   and eol is returned. Timeout in reading gives an empty binary.
%% @end
%%--------------------------------------------------------------------
-spec tcp_socket_to_data(inet:socket()) -> data(binary()).
%%--------------------------------------------------------------------
tcp_socket_to_data(TCPSocket) ->
    Promise = fun(Timeout, Socket) ->
                      case gen_tcp:recv(Socket, 0, Timeout) of
                          {ok, Packet} -> {Packet, Socket};
                          {error, timeout} -> {<<>>, Socket};
                          {error, closed} -> eol;
                          {error, _} -> tcp:close(Socket), eol
                      end
              end,
    create(Promise, TCPSocket).

%%--------------------------------------------------------------------
%% Function: file_to_data(Mode, FileName) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the stream, when opening the file
%%   in binary raw mode with read_ahead.
%%   On errors reading from the stream results in the closure
%%   and eol is returned.
%%   The mode determines if the data is read linewise or in chunks of
%%   Mode octets.
%% @end
%%--------------------------------------------------------------------
-spec file_to_data(line | integer(), file:filename()) ->
          data(binary()) | {error, file:posix() | badarg | system_limit}.
%%--------------------------------------------------------------------
file_to_data(Type, Name) ->
    case file:open(Name, [read, raw, read_ahead]) of
        {ok, Device} -> file_stream_to_data(Type, Device);
        Error = {error, _} -> Error
    end.

%%--------------------------------------------------------------------
%% Function: file_stream_to_data(Mode, Stream) -> LazyBinary
%% @doc
%%   A Lazy binary is constructed from the stream, it is expected to be
%%   opened in binary raw mode with read_ahead.
%%   On errors reading from the stream results in the closure
%%   and eol is returned.
%%   The mode determines if the data is read linewise or in chunks of
%%   Mode octets.
%% @end
%%--------------------------------------------------------------------
-spec file_stream_to_data(line | integer(), file:io_device()) -> data(binary()).
%%--------------------------------------------------------------------
file_stream_to_data(line, FileStream) ->
    Promise = fun(_, Stream) ->
                      case file:read_line(Stream) of
                          {ok, Data} -> {Data, Stream};
                          {error, _} -> file:close(Stream), eol;
                          eof -> file:close(Stream), eol
                      end
              end,
    create(Promise, FileStream);
file_stream_to_data(ChunkSize, FileStream) ->
    Promise = fun(_, Stream) ->
                      case file:read(Stream, ChunkSize) of
                          {ok, Data} -> {Data, Stream};
                          {error, _} -> file:close(Stream), eol;
                          eof -> file:close(Stream), eol
                      end
              end,
    create(Promise, FileStream).


%% ===================================================================
%% Internal functions.
%% ===================================================================
