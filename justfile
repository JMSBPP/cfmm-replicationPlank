# Local multi-chain helpers. `.env` is gitignored; CHAIN_A / CHAIN_B are RPC URLs.
# Ports match foundry.toml [rpc_endpoints] chainA / chainB.

# Ensure anvils on fixed ports, upsert CHAIN_A / CHAIN_B into `.env`, then
# source that file and fail unless both endpoints answer. Idempotent if already live.
init-chains:
    #!/usr/bin/env bash
    set -euo pipefail

    PORT_A=8545
    PORT_B=8646
    CHAIN_ID_A=31337
    CHAIN_ID_B=3138
    URL_A="http://127.0.0.1:${PORT_A}"
    URL_B="http://127.0.0.1:${PORT_B}"

    upsert_env() {
        local key="$1" val="$2" file=".env"
        touch "$file"
        if grep -q "^${key}=" "$file"; then
            sed -i "s|^${key}=.*|${key}=${val}|" "$file"
        else
            printf '%s=%s\n' "$key" "$val" >> "$file"
        fi
    }

    port_busy() {
        local port="$1"
        python3 -c "import socket; s = socket.socket(); s.settimeout(0.2); r = s.connect_ex(('127.0.0.1', int('${port}'))); s.close(); raise SystemExit(0 if r == 0 else 1)"
    }

    wait_live() {
        local url="$1" label="$2"
        local i
        for i in $(seq 1 50); do
            if cast chain-id --rpc-url "$url" >/dev/null 2>&1; then
                return 0
            fi
            sleep 0.1
        done
        echo "error: ${label} did not become live at ${url}" >&2
        return 1
    }

    ensure_anvil() {
        local port="$1" chain_id="$2" url="$3" label="$4"
        if cast chain-id --rpc-url "$url" >/dev/null 2>&1; then
            return 0
        fi
        if port_busy "$port"; then
            echo "error: ${label}: port ${port} is in use but not a live anvil RPC" >&2
            return 1
        fi
        anvil --host 127.0.0.1 --port "$port" --chain-id "$chain_id" >/dev/null 2>&1 &
        wait_live "$url" "$label"
    }

    ensure_anvil "$PORT_A" "$CHAIN_ID_A" "$URL_A" CHAIN_A
    ensure_anvil "$PORT_B" "$CHAIN_ID_B" "$URL_B" CHAIN_B

    upsert_env CHAIN_A "$URL_A"
    upsert_env CHAIN_B "$URL_B"

    set -a
    # shellcheck disable=SC1091
    source .env
    set +a

    wait_live "$CHAIN_A" CHAIN_A
    wait_live "$CHAIN_B" CHAIN_B

    echo "CHAIN_A=${CHAIN_A}"
    echo "CHAIN_B=${CHAIN_B}"
