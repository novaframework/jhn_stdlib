%%==============================================================================
%% Copyright 2016 Jan Henry Nystrom <JanHenryNystrom@gmail.com>
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
%%%   eunit unit tests for the chash library module.
%%% @end
%%%
%% @author Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%% @copyright (C) 2016, Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%%-------------------------------------------------------------------
-module(chash_tests).
-copyright('Jan Henry Nystrom <JanHenryNystrom@gmail.com>').

%% Includes
-include_lib("eunit/include/eunit.hrl").

%% ===================================================================
%% Tests.
%% ===================================================================

%%--------------------------------------------------------------------
%% jump/2
%%--------------------------------------------------------------------
jump_2_test_() ->
    [?_test(?assertEqual(
               [55,62,107,114,59,86,97,82,59,73,37,17,56,86,21,90,37,38,83,
                65,11,19,107,50,64,65,27,54,18,102,15,75,33,31,3,8,113,113,
                18,19,51,43,1,111,76,72,3,46,37,109,62,52,49,45,47,119,10,0,
                6,62,77,12,66,26,127,37,74,124,14,64,52,121,127,78,45,24,
                109,82,51,98,73,91,78,93,57,105,92,58,84,22,125,126,4,86,14,
                86,29,124,19,110,107,91,68,96,99,114,107,121,86,51,93,81,8,
                38,27,0,107,27,94,36,40,5,106,19,24,97,52,78,120,45,51,37,
                99,94,115,70,47,75,46,21,117,26,87,70,71,120,25,98,49,3,10,
                104,53,53,62,109,82,41,86,22,110,7,78,89,114,106,61,79,21,
                111,126,39,77,0,48,63,90,43,55,55,96,84,111,93,64,61,121,79,
                61,51,111,68,44,106,103,6,34,16,88,46,35,69,33,56,41,82,20,
                5,3,11,84,45,19,26,103,20,118,60,34,46,108,60,86,112,9,64,
                32,96,31,28,32,0,37,37,24,41,116,65,51,33,2,28,6,89,41,49,
                34,53,118,83,112,16,119,100,63,16,67,97,14,99,41,13,39,62,
                127,12,5,73,27,86,29,60,36,40,31,51,124,95,30,29,73,32,68,
                69,44,29,26,8,79,125,43,57,69,107,16,80,76,45,8,127,22,85,
                93,39,75,13,30,123,105,28,104,113,18,99,47,102,35,113,29,80,
                55,64,97,4,14,100,88,35,76,92,105,65,68,68,14,120,70,98,56,
                82,92,115,122,2,107,125,90,104,102,89,70,67,106,89,25,101,
                120,70,44,97,122,23,111,72,34,89,122,8,28,82,35,82,8,102,71,
                73,67,11,52,74,22,6,110,18,119,45,19,42,103,79,17,83,28,114,
                127,105,93,27,73,87,103,106,102,32,108,89,53,114,16,104,85,
                107,46,121,82,118,35,10,105,45,82,66,86,78,16,82,85,115,78,
                86,38,109,91,52,33,80,77,104,8,16,5,52,1,86,31,110,2,81,22,
                110,78,112,85,126,56,23,110,50,110,114,36,70,95,78,24,45,95,
                59,112,34,10,64,60,4,68,78,124,51,58,101,124,56,26,60,79,81,
                99,91,62,96,105,71,111,124,124,124,12,4,20,97,52,60,103,99,
                33,90,71,110,127,36,91,29,68,56,47,88,111,112,126,107,7,73,
                65,118,40,122,49,51,51,8,40,59,75,102,31,51,74,87,12,74,29,
                8,81,71,93,1,21,45,103,2,106,21,68,65,28,7,83,48,84,61,18,
                97,65,27,39,32,59,54,30,42,33,45,11,11,43,30,99,88,79,105,
                60,98,47,8,11,34,80,68,9,99,11,17,112,66,11,28,90,29,30,77,
                120,74,27,4,36,124,26,78,11,77,31,46,8,22,6,110,34,106,33,
                71,70,57,84,127,68,33,50,121,19,85,49,104,16,66,100,67,106,
                56,78,85,17,17,45,96,9,112,76,15,116,61,83,90,110,114,26,19,
                69,90,69,106,107,70,97,97,115,83,109,77,30,6,13,4,39,118,
                121,43,14,105,91,120,108,116,0,103,37,103,13,85,54,94,106,
                32,116,70,115,59,93,22,32,73,119,53,50,33,72,107,115,31,27,
                47,43,12,94,24,71,12,73,81,45,110,49,117,60,117,10,107,72,2,
                37,8,84,80,95,44,19,41,111,102,39,96,0,124,22,2,26,62,85,11,
                51,91,36,86,84,92,100,121,62,51,119,83,58,84,56,90,113,21,
                49,95,112,5,48,36,35,92,91,44,57,78,68,17,16,37,80,78,64,3,
                9,35,8,49,48,16,37,53,93,86,101,121,0,49,40,86,121,52,38,50,
                124,48,82,49,56,44,38,34,35,43,9,103,18,51,47,30,81,93,84,
                12,51,105,52,87,63,45,66,72,3,108,50,41,30,104,106,30,61,7,
                13,121,2,95,52,81,13,123,36,29,69,55,0,46,103,44,31,111,122,
                102,42,59,115,58,10,111,87,41,11,9,47,17,111,10,54,10,14,
                102,24,25,9,18,31,21,6,27,41,19,40,61,124,63,102,115,35,6,3,
                2,47,9,94,107,123,126,21,74,103,44,73,62,125,81,117,109,72,
                15,31,32,101,63,102,107,27,86,18,33,26,90,23,9,67,93,36,82,
                86,53,79,105,68,97,41,1,10,40,102,2,78,19,89,16,54,6,89,58,
                6,3,8,89,10,122,27,36,42,108,126,31,93,47,127,94,115,20,63,
                71,56,51,73,79,14,52,93,36,34,125,37,58,50,93,117,54,106,53,
                10,114,100,93],
               [chash:jump(N, 128) || N <- lists:seq(1, 1000)]))
           ].
%% ===================================================================
%% Internal functions.
%% ===================================================================
