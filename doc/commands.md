# SuperCollider OSC Commands

This document lists SuperCollider's [OSC commands](http://doc.sccode.org/Reference/Server-Command-Reference.html) (and replies) and, when implemented in factor-supercollider, the word(s) implementing them.

## Top-Level Commands
- `/quit` - `supercollider:quit-sc-server`
- `/notify`
- `/status`
- `/cmd`
- `/dumpOSC`
- `/sync`
- `/clearSched`
- `/error`
- `/version`

## Synth Definition Commands
- `/d_recv`
- `/d_load`
- `/d_loadDir`
- `/d_free`

## Node Commands
- `/n_free` - `supercollider.node:free-node`
- `/n_run`
- `/n_set` - `supercollider.node:control-node`
- `/n_setn`
- `/n_fill`
- `/n_map`
- `/n_mapn`
- `/n_mapa`
- `/n_mapan`
- `/n_before`
- `/n_after`
- `/n_query`
- `/n_trace`
- `/n_order`

## Synth Commands
- `/s_new` - `supercollider:launch-synth`, `supercollider.node:play-node`
- `/s_get`
- `/s_getn`
- `/s_noid`

## Group Commands
- `/g_new` - `supercollider.group:sc-server-new-group`
- `/p_new` - `supercollider.group:sc-server-new-parallel-group`
- `/g_head` - `supercollider.group:sc-server-move-nodes-group-head`
- `/g_tail` - `supercollider.group:sc-server-move-nodes-group-tail`
- `/g_freeAll` `supercollider.group:sc-server-group-free-all`
- `/g_deepFree` `supercollider.group:sc-server-group-deep-free`
- `/g_dumpTree` - `supercollider.group:dump-group-tree`, `supercollider.group:dump-group-tree+controls`
- `/g_queryTree` - `supercollider.group:group-query-tree`

## Unit Generator Commands
- `/u_cmd`

## Buffer Commands
- `/b_alloc`
- `/b_allocRead`
- `/b_allocReadChannel`
- `/b_read`
- `/b_readChannel`
- `/b_write`
- `/b_free`
- `/b_zero`
- `/b_set`
- `/b_setn`
- `/b_fill`
- `/b_gen`
- `/b_close`
- `/b_query`
- `/b_get`
- `/b_getn`

## Control Bus Commands
- `/c_set`
- `/c_setn`
- `/c_fill`
- `/c_get`
- `/c_getn`

## Non Real Time Mode Commands
- `/nrt_end`

## Replies to Commands
- `/done`
- `/fail`
- `/late`

## Node Notifications from Server
- `/n_go`
- `/n_end`
- `/n_off`
- `/n_on`
- `/n_move`
- `/n_info`

## Trigger Notification
- `/tr`

## Buffer Fill Commands
## Wave Fill Commands
## Other Commands
## Command Numbers
