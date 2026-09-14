#!/usr/bin/env bash
# impair.sh — apply/revert netem conditions on the LOCAL interface only.
# usage: ./impair.sh apply <loss%> <delay_ms> <jitter_ms> [rate_kbit]
#        ./impair.sh revert

set -e
IFACE=${IFACE:-$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')}

apply() {
  local loss=$1 delay=$2 jitter=$3 rate=$4
  sudo tc qdisc del dev "$IFACE" root 2>/dev/null || true
  if [ -n "$rate" ]; then
    sudo tc qdisc add dev "$IFACE" root handle 1: tbf rate "${rate}kbit" burst 32kbit latency 800ms
    sudo tc qdisc add dev "$IFACE" parent 1: handle 10: netem \
      delay "${delay}ms" "${jitter}ms" distribution normal loss "$loss%"
  else
    sudo tc qdisc add dev "$IFACE" root handle 1: netem \
      delay "${delay}ms" "${jitter}ms" distribution normal loss "$loss%"
  fi
  echo "[*] Applied: loss=${loss}% delay=${delay}±${jitter}ms rate=${rate:-unlimited}kbit on $IFACE"
}

revert() {
  sudo tc qdisc del dev "$IFACE" root 2>/dev/null || true
  echo "[*] Interface $IFACE restored"
}

case "${1:-}" in
  apply)  [ $# -lt 4 ] && { echo "usage: $0 apply <loss%> <delay_ms> <jitter_ms> [rate_kbit]"; exit 1; }
          apply "$2" "$3" "$4" "${5:-}" ;;
  revert) revert ;;
  *) echo "usage: $0 apply <loss%> <delay_ms> <jitter_ms> [rate_kbit] | revert"; exit 1 ;;
esac
