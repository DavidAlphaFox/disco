-type jobname() :: nonempty_string().
-type host_name() :: nonempty_string().

-type cores() :: non_neg_integer().

-record(jobinfo, {jobname :: jobname(),
                  jobfile :: nonempty_string(),
                  jobenvs :: [{nonempty_string(), string()}],
                  force_local :: boolean(),
                  force_remote :: boolean(),
                  owner :: binary(),
                  inputs :: [binary()] | [[binary()]],
                  worker :: binary(),
                  map :: boolean(),
                  max_cores :: cores(),
                  nr_reduce :: non_neg_integer(),
                  reduce :: boolean()}).
-type jobinfo() :: #jobinfo{}.

-record(nodeinfo, {name :: nonempty_string(),
                   connected :: boolean(),
                   blacklisted :: boolean(),
                   slots :: cores(),
                   num_running :: non_neg_integer(),
                   stats_ok :: non_neg_integer(),
                   stats_failed :: non_neg_integer(),
                   stats_crashed :: non_neg_integer()}).
-type nodeinfo() :: #nodeinfo{}.

-record(task, {chosen_input :: binary() | [binary()],
               force_local :: boolean(),
               force_remote :: boolean(),
               from :: pid(),
               input :: [{binary(), nonempty_string()}],
               jobenvs :: [{nonempty_string(), string()}],
               worker :: binary(),
               jobname :: jobname(),
               mode :: nonempty_string(), %"map" | "reduce"
               taskid :: non_neg_integer(),
               taskblack :: list(),
               fail_count :: non_neg_integer()}).
-type task() :: #task{}.

