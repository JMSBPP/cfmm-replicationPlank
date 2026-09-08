# Local multi-chain helpers. `.env` is gitignored; CHAIN_A / CHAIN_B are RPC URLs.

# Start two anvils on free ports, upsert CHAIN_A / CHAIN_B into `.env`, then
# source that file and fail unless both endpoints answer.
init-chains:
    #!/usr/bin/env bash
    set -euo pipefail

    free_port() {
        python3 -c 'import socket; s = socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'
    }

    upsert_env() {
        local key="$1" val="$2" file=".env"
        touch "$file"
        if grep -q "^${key}=" "$file"; then
            sed -i "s|^${key}=.*|${key}=${val}|" "$file"
        else
            printf '%s=%s\n' "$key" "$val" >> "$file"
        fi
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

    port_a="$(free_port)"
    port_b="$(free_port)"
    while [[ "$port_b" == "$port_a" ]]; do
        port_b="$(free_port)"
    done

    anvil --host 127.0.0.1 --port "$port_a" --chain-id 31337 >/dev/null 2>&1 &
    anvil --host 127.0.0.1 --port "$port_b" --chain-id 3138 >/dev/null 2>&1 &

    upsert_env CHAIN_A "http://127.0.0.1:${port_a}"
    upsert_env CHAIN_B "http://127.0.0.1:${port_b}"

    set -a
    # shellcheck disable=SC1091
    source .env
    set +a

    wait_live "$CHAIN_A" CHAIN_A
    wait_live "$CHAIN_B" CHAIN_B

    echo "CHAIN_A=${CHAIN_A}"
    echo "CHAIN_B=${CHAIN_B}"
