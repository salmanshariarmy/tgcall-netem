#!/usr/bin/env bash
# capture_endpoints.sh — identify the UDP media endpoints an RTC client
# (e.g., Telegram Desktop) connects to during a call. Local capture only.
# usage: ./capture_endpoints.sh [seconds]

set -u
IFACE=${IFACE:-$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')}
DUR=${1:-60}
OUT=call_capture_$(date +%s).pcap

[ -z "$IFACE" ] && { echo "[!] No default route/interface found"; exit 1; }
command -v tcpdump >/dev/null || { echo "[!] Install tcpdump: sudo apt install tcpdump"; exit 1; }

echo "[*] Capturing UDP on $IFACE for ${DUR}s. Join the group call NOW..."
sudo tcpdump -i "$IFACE" -n -w "$OUT" "udp and not port 53 and not port 123" &
TCPD_PID=$!
sleep "$DUR"
sudo kill "$TCPD_PID" 2>/dev/null
wait "$TCPD_PID" 2>/dev/null

echo "[*] Top UDP peers by packet count:"
sudo tcpdump -nn -r "$OUT" 2>/dev/null | \
  awk '{print $3"\n"$5}' | \
  sed 's/[.,]$//' | \
  grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | \
  awk -F. '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -rn | head -20

echo "[*] Capture saved: $OUT (kept local; excluded via .gitignore)"
