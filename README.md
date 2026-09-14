# tgcall-netem

Network-impairment test harness for characterizing real-time call behavior
(Telegram, Jitsi, LiveKit — any UDP-based RTC app) **from your own endpoint**.

Uses Linux `tc/netem` to apply packet loss, delay, jitter, and bandwidth
limits to the local machine's interface only. Includes a capture helper to
identify which media endpoints the client actually connects to.

## Scope & ethics

- All impairment applies to **your own interface and your own traffic**.
- No traffic is generated toward remote servers. This is NOT a load or DoS tool.
- Run only against services you are authorized to test.
- Interfering with third-party services is illegal (CFAA, Computer Misuse Act,
  and equivalents) and not supported by this tool.

## Requirements

- Linux (Kali, Ubuntu, Debian, Fedora) with `iproute2` and `tcpdump`
- Root/sudo
- An RTC client running on the **same machine** (e.g., Telegram Desktop for Linux)

## Setup

    git clone https://github.com/salmanshariarmy/tgcall-netem.git
    cd tgcall-netem
    chmod +x *.sh
    sudo apt install -y iproute2 tcpdump        # if missing

## Usage

    # 1. Discover media endpoints — join a call during the capture
    sudo ./capture_endpoints.sh 60

    # 2. Watch active flows live (optional, second terminal)
    watch -n1 "ss -tunp | grep -E '149.154|91.108'"

    # 3. Single manual test
    sudo ./impair.sh apply 10 200 30        # 10% loss, 200ms ±30ms jitter
    sudo ./impair.sh revert

    # 4. Full sweep (join a call first, stay in it)
    sudo ./matrix.sh --yes                  # DUR=60 sudo ./matrix.sh --yes for longer cases

## Emergency reset

    sudo tc qdisc del dev $(ip route get 1.1.1.1 | awk '{print $5; exit}') root
    sudo ip link set dev $(ip route get 1.1.1.1 | awk '{print $5; exit}') mtu 1500

## Results template

See `docs/test-matrix.md` for the case rationale and a blank results table.

## License


MIT License

Copyright (c) 2026 netem

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
