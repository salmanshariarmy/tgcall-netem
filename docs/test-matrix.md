# Test matrix rationale

| Case | Profile | What it reveals |
|---|---|---|
| baseline | no impairment | control reference |
| loss_l (1%) | good 4G | FEC headroom |
| loss_m (5%) | weak signal | adaptive bitrate behavior |
| loss_h (15%) | degraded | audio-only fallback threshold |
| loss_x (30%) | extreme | reconnect / call-drop point |
| delay_l (100ms±10) | intercontinental | latency tolerance |
| delay_h (400ms±50) | satellite | turn-taking / sync limits |
| jitter (50ms±80) | congested Wi-Fi | jitter buffer limits |
| mobile3g (10%, 200ms, 384kbit) | 3G | bandwidth floor for video |
| edge (25%, 400ms, 128kbit) | EDGE | audio survival floor |
| mtu 576 | fragmented links | fragmentation handling |

## Recording results

| Case | Audio | Video | Reconnect | UDP→TCP fallback | Notes |
|---|---|---|---|---|---|
| baseline | | | | | |
| loss_l | | | | | |
| loss_m | | | | | |
| loss_h | | | | | |
| loss_x | | | | | |
| delay_l | | | | | |
| delay_h | | | | | |
| jitter | | | | | |
| mobile3g | | | | | |
| edge | | | | | |
| mtu | | | | | |

Run each case twice; rejoin the call between sweeps for clean state.
