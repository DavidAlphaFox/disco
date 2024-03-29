-module(worker_throttle).
-export([init/0, handle/1]).

-define(MAX_EVENTS_PER_SECOND, 5).
-define(MICROSECONDS_IN_SECOND, 1000000).

-ifdef(namespaced_types).
-type state() :: queue:queue().
-else.
-type state() :: queue().
-endif.
-type throttle() :: {ok, non_neg_integer(), state()} | {error, term()}.

-export_type([state/0]).

-spec init() -> state().
init() ->
    queue:new().

-spec handle(state()) -> throttle().
handle(Q) ->
  Now = disco_util:timestamp(), %当前时间
    Q1 = queue:in(Now, Q),
    Diff = timer:now_diff(Now, queue:get(Q1)),
    if Diff > ?MICROSECONDS_IN_SECOND -> %当前时间和最久远的时间相差超过了1秒钟
        Q2 = queue:drop(Q1),
        throttle(Q2, queue:len(Q2)); %% 删除最久的时间，进行限流
    true ->
        throttle(Q1, queue:len(Q1))
    end.

-ifdef(namespaced_types).
-spec throttle(queue:queue(), non_neg_integer()) -> throttle().
-else.
-spec throttle(queue(), non_neg_integer()) -> throttle().
-endif.
%% 1秒钟超过了10件事件
throttle(_Q, N) when N >= ?MAX_EVENTS_PER_SECOND * 2 ->
    {error, ["Worker is behaving badly: Sent ",
             integer_to_list(N), " events in a second, ignoring replies."]};

throttle(Q, N) when N > ?MAX_EVENTS_PER_SECOND ->
    {ok, 1000 div ?MAX_EVENTS_PER_SECOND, Q};

throttle(Q, _N) ->
    {ok, 0, Q}.
