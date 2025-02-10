# SuperCollider OSC Commands

This document lists SuperCollider's [OSC commands](http://doc.sccode.org/Reference/Server-Command-Reference.html) (and replies) and, when implemented in factor-supercollider, the word(s) implementing them.

## Top-Level Commands
All words are defined in `supercollider.server`.
- `/quit` - `quit-sc-server`
- `/notify` - `sc-server-notify`, `sc-server-notify-enable`, `sc-server-notify-disable`, `sc-server-notify-client`
- `/status` - `sc-server-status`
- `/cmd` - `sc-server-plugin-command`
- `/dumpOSC` - `sc-server-dump-osc`, `sc-server-dump-osc-enable`, `sc-server-dump-osc-disable`
- `/sync` - `sc-server-sync`
- `/clearSched` - `sc-server-clear-scheduled`
- `/error` - `sc-server-report-errors`
- `/version` - `sc-server-version`

## Synth Definition Commands
All words are defined in `supercollider.synthdef`.
- `/d_recv` - `sc-server-send-synthdef`
- `/d_load` - `sc-server-load-synthdef`
- `/d_loadDir` - `sc-server-load-synthdef-directory`
- `/d_free` - `sc-server-free-synthdef`

## Node Commands
All words are defined in `supercollider.node`.
- `/n_free` - `free-node`, `sc-server-free-node`
- `/n_run` - `sc-server-run-node`
- `/n_set` - `control-node`, `sc-server-control-node`
- `/n_setn` - `sc-server-control-n-node`
- `/n_fill` - `sc-server-fill-node`
- `/n_map` - `sc-server-map-node`
- `/n_mapn` - `sc-server-map-n-node`
- `/n_mapa` - `sc-server-map-audio-node`
- `/n_mapan` - `sc-server-map-audio-n-node`
- `/n_before` - `sc-server-before-node`
- `/n_after` - `sc-server-after-node`
- `/n_query` - `sc-server-query-node`
- `/n_trace` - `sc-server-trace-node`
- `/n_order` - `sc-server-order-node`

## Synth Commands
All words are defined in `supercollider.node`.
- `/s_new` - `supercollider:launch-synth`, `play-node`, `sc-server-play-synth`
- `/s_get` - `sc-server-get-synth-controls`
- `/s_getn` - `sc-server-get-n-synth-controls`
- `/s_noid` - `sc-server-unassign-synth-id`

## Group Commands
All words are defined in `supercollider.group`.
- `/g_new` - `sc-server-new-group`
- `/p_new` - `sc-server-new-parallel-group`
- `/g_head` - `sc-server-move-nodes-group-head`
- `/g_tail` - `sc-server-move-nodes-group-tail`
- `/g_freeAll` - `sc-server-group-free-all`
- `/g_deepFree` - `sc-server-group-deep-free`
- `/g_dumpTree` - `dump-group-tree`, `dump-group-tree+controls`
- `/g_queryTree` - `group-query-tree`

## Unit Generator Commands
All words are defined in `supercollider.ugen`.
- `/u_cmd` - `sc-server-ugen-command`

## Buffer Commands
All words are defined in `supercollider.buffer`.
- `/b_alloc` - `sc-server-buffer-alloc`
- `/b_allocRead` - `sc-server-buffer-alloc-read`
- `/b_allocReadChannel`
- `/b_read` - `sc-server-buffer-read`
- `/b_readChannel`
- `/b_write` - `sc-server-buffer-write`
- `/b_free` - `sc-server-buffer-free`
- `/b_zero` - `sc-server-buffer-zero`
- `/b_set` - `sc-server-buffer-set`
- `/b_setn` - `sc-server-buffer-set-n`
- `/b_fill` - `sc-server-buffer-fill`
- `/b_gen` - `sc-server-buffer-gen`
- `/b_close` - `sc-server-buffer-close`
- `/b_query` - `sc-server-buffer-query`
- `/b_get` - `sc-server-buffer-get`
- `/b_getn` - `sc-server-buffer-getn`

## Control Bus Commands
All words are defined in `supercollider.bus`.
- `/c_set` - `sc-server-bus-set`
- `/c_setn` - `sc-server-bus-set-n`
- `/c_fill` - `sc-server-bus-fill`
- `/c_get` - `sc-server-bus-get`
- `/c_getn` - `sc-server-bus-get-n`

## Non Real Time Mode Commands
- `/nrt_end` - not implemented in SuperCollider.

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
