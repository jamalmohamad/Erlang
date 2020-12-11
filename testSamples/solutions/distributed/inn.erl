-module(inn).
-compile(export_all).




% create a node called inn and run the goblins there.
% {inn, inn@localhost}
% this function is finished do not play with it 

create_goblins(N) when N >= 10 -> exit;
create_goblins(N) when N < 10 ->
     Spawn =  fun(_X) ->
                    Name = randGoblinNames(6),
                    %Pid = spawn(inn@localhost, fun() -> receive _A -> goblin() end end),
                    Pid = spawn(inn@localhost, fun() -> goblin() end),
                    io:format("Pid is: ~p~n", [Pid]),
                    global:register_name(Name, Pid)
                end,
                
        [Spawn(X) || X <- lists:seq(1,N)],

        io:format("registered goblins are ~p~n", [global:registered_names()]).



% randGoblinNames(N)  where N is a number for word long
randGoblinNames(N) -> randGoblinNames(N, []).

randGoblinNames(0, Acc) -> Acc;
randGoblinNames(N, Acc) -> randGoblinNames(N - 1, [rand:uniform(26) + 96 | Acc]).




% {traveller, traveller@localhost}

%%%%%%%%%%%%%%%% Traveler Implementation %%%%%%%%%%%%%%%%%%%%%%%
traveler() ->
    Traveller = spawn('traveler@localhost', ?MODULE, inn_adventure, []).





%%%%%%%%%%%%%%%%% Inn Adventure Implementation %%%%%%%%%%%%%%%%
inn_adventure() ->
    
    %GoblinsList = global:registered_names(),
    % GoblinID ==  index of distinct if Distinct = 3 then bring goblin id in index 3 then get the id
    
     %Goblin = lists:nth(DINSTINCT, GoblinsList),
    % GoblinId = global:whereis_name(Goblin),
    % global:register_name(gid, GoblinId), % already registered no need for register again
    % io:format("global registered goblins are ~p~nlength of them are ~p~nDistinct is ~p~nthe Goblin is ~p~nGoblinId is ~p~n", [global:registered_names(), N, DINSTINCT, Goblin, GoblinId]),
    % send allow message to goblin and usse_bed

    GoblinsList = global:registered_names(),
    TravellerId = self(),
    Message =  {use_bed, TravellerId},

     N = length(global:registered_names()),
    DINSTINCT = (N div 2 + 1),

     %Goblin = lists:nth(DINSTINCT, GoblinsList),
    % GoblinId = global:whereis_name(Goblin),

    %global:send(Goblin, Message).
   lists:map(
        fun(Name) -> 
        global:send(Name, Message),
        io:format("traveller: Goblin ~p received ~p~n", [Name, Message])
    end, GoblinsList).

   
    
    % if DINSTINCT rem 2 == 0 -> 
    %     io:format("~p~n",[{granted, GoblinId}]),
    %     receive
    %         {on_bed, GoblinId} -> im_on_bed
    %     after 3000 -> timeout
    %     end;
        
        
    %     true -> 
    %         io:format("~p~n",[{grunted, GoblinId}]),
    %         receive
    %         after 300 -> inn_adventure()
    %         end
    % end.

    



goblin() ->
    GoblinsList = global:registered_names(),
    Bed = free,
    receive 
        {use_bed, TravelerId} ->
            lists:map(fun(Name) -> 
                io:format("inn: I am Goblin ~p received ~p~n", [Name, {use_bed, TravelerId}]) end, GoblinsList), goblin(),
            handlebed(TravelerId, Bed, diceroll(6))
                % receive
                %    {on_bed, TravelerId} ->
                %            on_bed;
                %    {leaving_bed, TravelerId} ->
                %            free 
                % end
    end.

%net_adm:ping('inn@localhost').


%%%%%%%%%%%%%%%%%%%%%%%%%%% backend %%%%%%%%%%%%%%%%%%%%%%%%

% how to call handlebed/3 from terminal
% > Pid = pid(0,120,0).
% > c(inn).
% > inn:create_goblins(4).
% > inn:handlebed(Pid, on_bed, inn:diceroll(6)).
% {grunt,<0.120.0>}


handlebed(TravelerId, Bed, DiceRoll) when DiceRoll =< 6 ->   % TravelerId here is the inn_adventure function Pid
    self(),
    case DiceRoll of 
        1 ->
            if Bed == free ->
                TravelerId ! {grunt, TravelerId};   % not allowed to pass
                true -> TravelerId ! {grunt, TravelerId} % bed_not_free % handlebed(TravelerId, Bed, diceroll(6))
            end;
        5 ->
            if Bed == free ->
                TravelerId ! {grant, TravelerId};
            true -> TravelerId ! {grant, TravelerId} 
            end;
        _ ->
            if Bed =/= free ->
                if TravelerId =/= self() ->    % self() here means a different Pid   (Bed is not free but a different Pid)
                    TravelerId ! {grunt, TravelerId};
                    true -> is_equal
                end;
            true -> Bed
            end
        end.


% diceroll random number generation
diceroll(N) when N > 6  -> 0; 
diceroll(N) when N =< 6 ->
    rand:uniform(N).







%%%%%%%%%%%%%%%%%%%% Game Over Implementation %%%%%%%%%%%%%%%%%%%%%%%
% kills all goblins and its monitors
sentinel() ->
    GetRegisteredGoblins = global:registered_names(),
    sentinel_helper(GetRegisteredGoblins).


sentinel_helper([]) -> all_monitored_goblins_are_dead;
sentinel_helper([P|Pids]) ->
    MRef = erlang:monitor(process, global:whereis_name(P)),
    io:format("goblin ~p with pid of ~p and Ref of ~p is killed ~p~n", [P, global:whereis_name(P), MRef, exit(global:whereis_name(P), kill)]),
    %erlang:flush(),
    sentinel_helper(Pids).    
    


% kill all the goblins
gameover() ->
    LstOfRegGoblins = global:registered_names(),
    gameOverHelper(LstOfRegGoblins).


gameOverHelper([]) -> all_goblins_are_dead;
gameOverHelper([P|Pids]) ->
    io:format("goblin ~p with pid of ~p is dead ~p~n", [P, global:whereis_name(P), exit(global:whereis_name(P), dead)]),
    gameOverHelper(Pids).

















% instructions to execute 
% inn@localhost> net_adm:ping('traveler@localhost').
% inn@localhost> net_adm:ping('traveler1@localhost').
% inn@localhost> c(inn).
% inn@localhost> inn:create_goblins(6).
% inn@localhost>






% traveler@localhost>inn:traveler().



% traveler1@localhost> inn:traveler().