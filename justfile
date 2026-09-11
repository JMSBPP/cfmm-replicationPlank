# Pinned Algebra Solidity sources live under node_modules (see package.json).
npm-ci:
    npm ci --ignore-scripts

# Export a volatility-oracle-plugin library creation bytecode via forge inspect.
# Usage: just bytecode VolatilityOracle
#        just bytecode VolatilityOracleStorage
# Prerequisite: `just npm-ci` (or `npm ci --ignore-scripts`).
# Isolated --root: copies all sibling libraries/ (relative imports) and avoids the
# repo foundry.toml pulling missing lib/ submodules (forge-std, …).
bytecode file:
    #!/usr/bin/env bash
    set -euo pipefail
    libdir="node_modules/@cryptoalgebra/volatility-oracle-plugin/contracts/libraries"
    src="$libdir/{{file}}.sol"
    if [[ ! -f "$src" ]]; then
        echo "error: missing $src" >&2
        echo "run: just npm-ci   # or: npm ci --ignore-scripts" >&2
        exit 1
    fi
    out=".bytecode/algebra/volatility_plugin"
    mkdir -p "$out"
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/src"
    # Sibling libs (e.g. VolatilityOracleStorage → ./VolatilityOracle.sol).
    cp "$libdir"/*.sol "$tmp/src/"
    {
        echo "[profile.default]"
        echo 'src = "src"'
        echo 'out = "out"'
        echo 'solc = "0.8.20"'
        echo 'via_ir = true'
        echo 'optimizer = true'
    } > "$tmp/foundry.toml"
    forge inspect --root "$tmp" "{{file}}" bytecode \
        > "$out/{{file}}Lib.bytecode"

# Runtime / creation bytecode for VolatilityOraclePluginImplementation.
# Writes:
#   .bytecode/algebra/volatility_plugin/VolatilityOraclePluginImplementation.runtime.bytecode
#   .bytecode/algebra/volatility_plugin/VolatilityOraclePluginImplementation.bytecode
# Prerequisite: `just npm-ci`
bytecode-runtime:
    #!/usr/bin/env bash
    set -euo pipefail
    root="$(pwd)"
    out="$root/.bytecode/algebra/volatility_plugin"
    mkdir -p "$out"

    impl_json="$root/node_modules/@cryptoalgebra/volatility-oracle-plugin/artifacts/contracts/VolatilityOraclePluginImplementation.sol/VolatilityOraclePluginImplementation.json"
    if [[ ! -f "$impl_json" ]]; then
        echo "error: missing $impl_json" >&2
        echo "run: just npm-ci" >&2
        exit 1
    fi
    jq -r '.deployedBytecode | if type == "string" then . else .object end' "$impl_json" \
        | tr -d '\n' > "$out/VolatilityOraclePluginImplementation.runtime.bytecode"
    jq -r '.bytecode | if type == "string" then . else .object end' "$impl_json" \
        | tr -d '\n' > "$out/VolatilityOraclePluginImplementation.bytecode"
    echo "wrote $out/VolatilityOraclePluginImplementation.runtime.bytecode ($(wc -c < "$out/VolatilityOraclePluginImplementation.runtime.bytecode") bytes)"
    echo "wrote $out/VolatilityOraclePluginImplementation.bytecode ($(wc -c < "$out/VolatilityOraclePluginImplementation.bytecode") bytes)"

help:
	cat .offline/plank.helper

plank file:
    #!/usr/bin/env bash
    set -euo pipefail
    # Prefer explicit PLANK, then install path, then pinned release build, then PATH.
    if [[ -n "${PLANK:-}" && -x "${PLANK}" ]]; then
        plank_bin="$PLANK"
    elif [[ -x "$HOME/.plank/bin/plank" ]]; then
        plank_bin="$HOME/.plank/bin/plank"
    elif [[ -x lib/plank-monorepo/plankc/target/release/plank ]]; then
        plank_bin="lib/plank-monorepo/plankc/target/release/plank"
    elif command -v plank >/dev/null 2>&1; then
        plank_bin="$(command -v plank)"
    else
        echo "error: plank not found (missing/broken \$HOME/.plank/bin/plank)" >&2
        echo "run: make plank-toolchain" >&2
        exit 127
    fi
    "$plank_bin" build {{file}} \
        --dep v3=lib/plankified-univ3/plank/lib \
        --dep std=lib/plank-monorepo/std/ \
        --dep types=src/types/ \
        --dep cfmm_types=lib/cfmm-types/src/types/ \
        --dep lib=src/lib/ \
        --backend sona
