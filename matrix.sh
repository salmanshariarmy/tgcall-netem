#!/usr/bin/env bash
# matrix.sh — run the full impairment sweep. Join the call BEFORE starting,
# stay in it during the run. Shapes ONLY the local interface.

CASES=(
  "baseline   0   0   0  -"
  "loss_l     1   0   0  -"
  "loss_m     5   0   0  -"
  "loss_h    15   0   0  -"
  "loss_x    30   0   0  -"
  "delay_l    0 100  10  -"
  "delay_h    0 400  50  -"
  "jitter     0  50  80  -"
  "mobile3g  10 200  30 384"
  "edge      25 400  60 128"
  "mtu        0   0   0  -"
)

if [ "${1:-}" != "--yes" ]; then
  echo "This will degrade YOUR machine's network during the run."
  echo "Run with: $0 --yes   (optionally DUR=60 $0 --yes)"
  exit 1
fi

IFACE=${IFACE:-$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')}
DUR=${DUR:-45}
HERE=$(cd "$(dirname "$0")" && pwd)
LOG=matrix_results_$(date +%s).log

for c in "${CASES[@]}"; do
  read -r name loss delay jitter rate <<< "$c"
  echo "=== CASE: $name (loss=$loss delay=${delay}±${jitter}ms rate=$rate) ===" | tee -a "$LOG"
  if [ "$name" == "mtu" ]; then
    sudo ip link set dev "$IFACE" mtu 576
    echo "[*] MTU reduced to 576" | tee -a "$LOG"
  else
    "$HERE/impair.sh" apply "$loss" "$delay" "$jitter" "$rate"
  fi
  ss -tunap > "snapshot_${name}.txt" 2>/dev/null || true
  sleep "$DUR"
  sudo ip link set dev "$IFACE" mtu 1500
  "$HERE/impair.sh" revert
  echo "=== END: $name — record: audio | video | reconnect | fallback ===" | tee -a "$LOG"
  sleep 10
done
"$HERE/impair.sh" revert
echo "[*] Done. Log: $LOG"
