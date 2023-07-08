# SuperCollider OSC Commands

This document lists SuperCollider's [OSC commands](http://doc.sccode.org/Reference/Server-Command-Reference.html) (and replies) and, when implemented in factor-supercollider, the word(s) implementing them.

## Top-Level Commands
All words are defined in `supercollider.server` unless otherwise specified.
- `/quit` - `quit-sc-server`
- `/notify`
- `/status` - `sc-server-status`
- `/cmd`
- `/dumpOSC`
- `/sync`
- `/clearSched`
- `/error`
- `/version`

## Synth Definition Commands
All words are defined in `supercollider.synthdef` unless otherwise specified.
- `/d_recv`
- `/d_load`
- `/d_loadDir`
- `/d_free`

## Node Commands
All words are defined in `supercollider.node` unless otherwise specified.
- `/n_free` - `free-node`
- `/n_run`
- `/n_set` - `control-node`
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
All words are defined in `supercollider.node` unless otherwise specified.
- `/s_new` - `supercollider:launch-synth`, `supercollider.node:play-node`
- `/s_get`
- `/s_getn`
- `/s_noid`

## Group Commands
All words are defined in `supercollider.group` unless otherwise specified.
- `/g_new` - `sc-server-new-group`
- `/p_new` - `sc-server-new-parallel-group`
- `/g_head` - `sc-server-move-nodes-group-head`
- `/g_tail` - `sc-server-move-nodes-group-tail`
- `/g_freeAll` - `sc-server-group-free-all`
- `/g_deepFree` - `sc-server-group-deep-free`
- `/g_dumpTree` - `dump-group-tree`, `dump-group-tree+controls`
- `/g_queryTree` - `group-query-tree`

## Unit Generator Commands
All words are defined in `supercollider.ugen` unless otherwise specified.
- `/u_cmd` - `sc-server-ugen-command`

## Buffer Commands
All words are defined in `supercollider.buffer` unless otherwise specified.
- `/b_alloc` - `sc-server-buffer-alloc`
- `/b_allocRead` - `sc-server-buffer-alloc-read`
- `/b_allocReadChannel`
- `/b_read` - `sc-server-buffer-read`
- `/b_readChannel`
- `/b_write` - `sc-server-buffer-write`
- `/b_free` - `sc-server-buffer-free`
- `/b_zero` - `sc-server-buffer-zero`
- `/b_set` - `sc-server-buffer-set`
- `/b_setn` - `sc-server-buffer-setn`
- `/b_fill` - `sc-server-buffer-fill`
- `/b_gen` - `sc-server-buffer-gen`
- `/b_close` - `sc-server-buffer-close`
- `/b_query` - `sc-server-buffer-query`
- `/b_get` - `sc-server-buffer-get`
- `/b_getn` - `sc-server-buffer-getn`

## Control Bus Commands
All words are defined in `supercollider.bus` unless otherwise specified.
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

### Wave Fill Commands
- `sine1` - `buffer-fill-sine1`
- `sine2` - `buffer-fill-sine2`
- `sine3` - `buffer-fill-sine3`
- `cheby` - `buffer-fill-cheby`

### Other Commands
- `copy` - `buffer-fill-copy`
