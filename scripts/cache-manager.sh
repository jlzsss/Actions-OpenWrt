#!/usr/bin/env bash

set -euo pipefail

CACHE_ROOT="${CACHE_ROOT:-/mnt/cache}"
CACHE_METADATA="${CACHE_ROOT}/.cache-metadata"
CACHE_STATS="${CACHE_ROOT}/.cache-stats"
CACHE_VERSION="1.0"
MAX_CACHE_AGE_DAYS="${MAX_CACHE_AGE_DAYS:-7}"
MAX_CACHE_SIZE_GB="${MAX_CACHE_SIZE_GB:-50}"
LOG_FILE="${CACHE_ROOT}/cache.log"

CACHE_TYPES=(
    "dl:downloaded source packages:7"
    "build_dir:build artifacts:7"
    "staging_dir:toolchain and staging:30"
    "tmp:temporary files:1"
    "ccache:compiler cache:30"
    "openwrt:source tree:7"
)

log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

init_cache() {
    log "INFO" "Initializing cache system v${CACHE_VERSION}"
    mkdir -p "$CACHE_ROOT"
    
    if [ ! -f "$CACHE_METADATA" ]; then
        echo "version=$CACHE_VERSION" > "$CACHE_METADATA"
        echo "initialized=$(date -u +%s)" >> "$CACHE_METADATA"
        log "INFO" "Created cache metadata"
    fi
    
    if [ ! -f "$CACHE_STATS" ]; then
        cat > "$CACHE_STATS" << 'EOF'
cache_hits=0
cache_misses=0
cache_saves=0
cache_evictions=0
total_bytes_saved=0
total_bytes_stored=0
EOF
        log "INFO" "Initialized cache statistics"
    fi
    
    for cache_type in "${CACHE_TYPES[@]}"; do
        local name="${cache_type%%:*}"
        mkdir -p "${CACHE_ROOT}/${name}"
    done
    
    log "INFO" "Cache system initialized successfully"
}

get_cache_key() {
    local cache_type="$1"
    local identifier="$2"
    local config_hash=""
    
    if [ -f "${GITHUB_WORKSPACE:-}/.config" ]; then
        config_hash=$(sha256sum "${GITHUB_WORKSPACE}/.config" 2>/dev/null | cut -d' ' -f1 || echo "noconfig")
    fi
    
    echo "${cache_type}:${identifier}:${config_hash}"
}

get_cache_path() {
    local cache_type="$1"
    local cache_key="$2"
    echo "${CACHE_ROOT}/${cache_type}/$(echo -n "$cache_key" | sha256sum | cut -d' ' -f1)"
}

is_cache_valid() {
    local cache_path="$1"
    local cache_type="$2"
    
    if [ ! -d "$cache_path" ]; then
        return 1
    fi
    
    local metadata_file="${cache_path}/.metadata"
    if [ ! -f "$metadata_file" ]; then
        return 1
    fi
    
    local created_at
    created_at=$(grep "^created_at=" "$metadata_file" | cut -d'=' -f2)
    local current_time
    current_time=$(date -u +%s)
    local age_days=$(( (current_time - created_at) / 86400 ))
    
    for cache_type_info in "${CACHE_TYPES[@]}"; do
        local name="${cache_type_info%%:*}"
        local max_age="${cache_type_info##*:}"
        
        if [ "$name" = "$cache_type" ] && [ "$age_days" -gt "$max_age" ]; then
            log "WARN" "Cache expired: ${cache_path} (age: ${age_days} days, max: ${max_age} days)"
            return 1
        fi
    done
    
    return 0
}

store_cache() {
    local cache_type="$1"
    local source_path="$2"
    local identifier="${3:-default}"
    
    if [ ! -d "$source_path" ]; then
        log "WARN" "Source path does not exist: ${source_path}"
        return 1
    fi
    
    local cache_key
    cache_key=$(get_cache_key "$cache_type" "$identifier")
    local cache_path
    cache_path=$(get_cache_path "$cache_type" "$cache_key")
    
    log "INFO" "Storing cache: ${cache_type} from ${source_path}"
    
    mkdir -p "$cache_path"
    
    local source_size
    source_size=$(du -sb "$source_path" 2>/dev/null | cut -f1 || echo "0")
    
    rsync -a --delete "$source_path/" "${cache_path}/" 2>/dev/null || {
        log "ERROR" "Failed to sync cache: ${source_path} -> ${cache_path}"
        rm -rf "$cache_path"
        return 1
    }
    
    cat > "${cache_path}/.metadata" << EOF
cache_key=${cache_key}
cache_type=${cache_type}
identifier=${identifier}
created_at=$(date -u +%s)
size_bytes=${source_size}
version=${CACHE_VERSION}
EOF
    
    update_stat "cache_saves" 1
    update_stat "total_bytes_stored" "$source_size"
    
    log "INFO" "Cache stored successfully: ${cache_path} ($(numfmt --to=iec-i --suffix=B $source_size 2>/dev/null || echo ${source_size}B))"
    
    check_and_evict_cache
}

restore_cache() {
    local cache_type="$1"
    local dest_path="$2"
    local identifier="${3:-default}"
    
    mkdir -p "$dest_path"
    
    local cache_key
    cache_key=$(get_cache_key "$cache_type" "$identifier")
    local cache_path
    cache_path=$(get_cache_path "$cache_type" "$cache_key")
    
    if ! is_cache_valid "$cache_path" "$cache_type"; then
        log "INFO" "Cache miss: ${cache_type} (not found or expired)"
        update_stat "cache_misses" 1
        return 1
    fi
    
    log "INFO" "Restoring cache: ${cache_type} to ${dest_path}"
    
    local metadata_file="${cache_path}/.metadata"
    local cached_size
    cached_size=$(grep "^size_bytes=" "$metadata_file" | cut -d'=' -f2)
    
    rsync -a --delete "${cache_path}/" "${dest_path}/" 2>/dev/null || {
        log "ERROR" "Failed to restore cache: ${cache_path} -> ${dest_path}"
        return 1
    }
    
    update_stat "cache_hits" 1
    update_stat "total_bytes_saved" "$cached_size"
    
    log "INFO" "Cache restored successfully: ${cache_type} ($(numfmt --to=iec-i --suffix=B $cached_size 2>/dev/null || echo ${cached_size}B))"
    
    return 0
}

check_and_evict_cache() {
    local total_size_bytes
    total_size_bytes=$(du -sb "$CACHE_ROOT" 2>/dev/null | cut -f1 || echo "0")
    local max_size_bytes=$((MAX_CACHE_SIZE_GB * 1024 * 1024 * 1024))
    
    if [ "$total_size_bytes" -le "$max_size_bytes" ]; then
        return 0
    fi
    
    log "WARN" "Cache size exceeds limit: $(numfmt --to=iec-i --suffix=B $total_size_bytes 2>/dev/null || echo ${total_size_bytes}B) > ${MAX_CACHE_SIZE_GB}GB"
    
    local cache_entries=()
    while IFS= read -r -d '' entry; do
        if [ -f "${entry}/.metadata" ]; then
            cache_entries+=("$entry")
        fi
    done < <(find "${CACHE_ROOT}" -maxdepth 2 -type d -print0)
    
    IFS=$'\n' sorted_entries=($(sort -t'/' -k3 -r <<<"${cache_entries[*]}"))
    
    for entry in "${sorted_entries[@]}"; do
        local metadata_file="${entry}/.metadata"
        local cache_type
        cache_type=$(grep "^cache_type=" "$metadata_file" | cut -d'=' -f2)
        local created_at
        created_at=$(grep "^created_at=" "$metadata_file" | cut -d'=' -f2)
        local current_time
        current_time=$(date -u +%s)
        local age_days=$(( (current_time - created_at) / 86400 ))
        
        for cache_type_info in "${CACHE_TYPES[@]}"; do
            local name="${cache_type_info%%:*}"
            local max_age="${cache_type_info##*:}"
            
            if [ "$name" = "$cache_type" ] && [ "$age_days" -gt "$((max_age / 2))" ]; then
                log "INFO" "Evicting cache: ${entry} (age: ${age_days} days)"
                rm -rf "$entry"
                update_stat "cache_evictions" 1
                
                total_size_bytes=$(du -sb "$CACHE_ROOT" 2>/dev/null | cut -f1 || echo "0")
                if [ "$total_size_bytes" -le "$max_size_bytes" ]; then
                    log "INFO" "Cache size within limit after eviction"
                    return 0
                fi
            fi
        done
    done
}

clear_cache() {
    local cache_type="${1:-all}"
    
    if [ "$cache_type" = "all" ]; then
        log "INFO" "Clearing all cache"
        rm -rf "${CACHE_ROOT:?}"/*
        init_cache
    else
        log "INFO" "Clearing cache type: ${cache_type}"
        rm -rf "${CACHE_ROOT}/${cache_type:?}"/*
    fi
    
    log "INFO" "Cache cleared successfully"
}

update_stat() {
    local stat_name="$1"
    local stat_value="$2"
    
    if [ ! -f "$CACHE_STATS" ]; then
        return 1
    fi
    
    sed -i "s/^${stat_name}=.*/${stat_name}=${stat_value}/" "$CACHE_STATS"
}

get_stat() {
    local stat_name="$1"
    
    if [ ! -f "$CACHE_STATS" ]; then
        echo "0"
        return
    fi
    
    grep "^${stat_name}=" "$CACHE_STATS" | cut -d'=' -f2 || echo "0"
}

show_stats() {
    log "INFO" "Cache Statistics:"
    echo "===================="
    echo "Cache Version: ${CACHE_VERSION}"
    echo "Cache Root: ${CACHE_ROOT}"
    echo "Max Cache Age: ${MAX_CACHE_AGE_DAYS} days"
    echo "Max Cache Size: ${MAX_CACHE_SIZE_GB} GB"
    echo ""
    echo "Performance Metrics:"
    echo "  Cache Hits: $(get_stat 'cache_hits')"
    echo "  Cache Misses: $(get_stat 'cache_misses')"
    echo "  Cache Saves: $(get_stat 'cache_saves')"
    echo "  Cache Evictions: $(get_stat 'cache_evictions')"
    echo ""
    
    local total_bytes_saved
    total_bytes_saved=$(get_stat 'total_bytes_saved')
    local total_bytes_stored
    total_bytes_stored=$(get_stat 'total_bytes_stored')
    
    echo "Storage Metrics:"
    echo "  Total Bytes Saved: $(numfmt --to=iec-i --suffix=B $total_bytes_saved 2>/dev/null || echo ${total_bytes_saved}B)"
    echo "  Total Bytes Stored: $(numfmt --to=iec-i --suffix=B $total_bytes_stored 2>/dev/null || echo ${total_bytes_stored}B)"
    
    if [ "$total_bytes_saved" -gt 0 ]; then
        local hit_rate
        hit_rate=$(awk "BEGIN {printf \"%.2f\", ($(get_stat 'cache_hits') / ($(get_stat 'cache_hits') + $(get_stat 'cache_misses'))) * 100}")
        echo "  Cache Hit Rate: ${hit_rate}%"
    fi
    
    echo ""
    echo "Current Cache Usage:"
    for cache_type_info in "${CACHE_TYPES[@]}"; do
        local name="${cache_type_info%%:*}"
        local desc="${cache_type_info#*:}"
        local desc="${desc%:*}"
        
        if [ -d "${CACHE_ROOT}/${name}" ]; then
            local size_bytes
            size_bytes=$(du -sb "${CACHE_ROOT}/${name}" 2>/dev/null | cut -f1 || echo "0")
            local entry_count
            entry_count=$(find "${CACHE_ROOT}/${name}" -maxdepth 1 -type d 2>/dev/null | wc -l)
            entry_count=$((entry_count - 1))
            
            echo "  ${name} (${desc}):"
            echo "    Size: $(numfmt --to=iec-i --suffix=B $size_bytes 2>/dev/null || echo ${size_bytes}B)"
            echo "    Entries: ${entry_count}"
        fi
    done
    
    local total_size_bytes
    total_size_bytes=$(du -sb "$CACHE_ROOT" 2>/dev/null | cut -f1 || echo "0")
    echo "  Total: $(numfmt --to=iec-i --suffix=B $total_size_bytes 2>/dev/null || echo ${total_size_bytes}B)"
}

validate_cache() {
    local cache_type="${1:-all}"
    local errors=0
    
    log "INFO" "Validating cache: ${cache_type}"
    
    if [ "$cache_type" = "all" ]; then
        for cache_type_info in "${CACHE_TYPES[@]}"; do
            local name="${cache_type_info%%:*}"
            validate_cache "$name"
        done
        return
    fi
    
    local cache_dir="${CACHE_ROOT}/${cache_type}"
    if [ ! -d "$cache_dir" ]; then
        log "WARN" "Cache directory does not exist: ${cache_dir}"
        return 1
    fi
    
    while IFS= read -r -d '' entry; do
        if [ -f "${entry}/.metadata" ]; then
            local metadata_file="${entry}/.metadata"
            local cache_key
            cache_key=$(grep "^cache_key=" "$metadata_file" | cut -d'=' -f2)
            local cache_type_check
            cache_type_check=$(grep "^cache_type=" "$metadata_file" | cut -d'=' -f2)
            
            if [ "$cache_type_check" != "$cache_type" ]; then
                log "ERROR" "Cache type mismatch in ${entry}"
                errors=$((errors + 1))
            fi
            
            if ! is_cache_valid "$entry" "$cache_type"; then
                log "WARN" "Invalid cache entry: ${entry}"
                rm -rf "$entry"
            fi
        fi
    done < <(find "${cache_dir}" -maxdepth 1 -type d -print0)
    
    if [ "$errors" -eq 0 ]; then
        log "INFO" "Cache validation passed: ${cache_type}"
        return 0
    else
        log "ERROR" "Cache validation failed: ${cache_type} (${errors} errors)"
        return 1
    fi
}

cleanup_expired_cache() {
    log "INFO" "Cleaning up expired cache entries"
    
    local cleaned=0
    for cache_type_info in "${CACHE_TYPES[@]}"; do
        local name="${cache_type_info%%:*}"
        local cache_dir="${CACHE_ROOT}/${name}"
        
        if [ ! -d "$cache_dir" ]; then
            continue
        fi
        
        while IFS= read -r -d '' entry; do
            if [ -f "${entry}/.metadata" ]; then
                if ! is_cache_valid "$entry" "$name"; then
                    log "INFO" "Removing expired cache: ${entry}"
                    rm -rf "$entry"
                    cleaned=$((cleaned + 1))
                fi
            fi
        done < <(find "${cache_dir}" -maxdepth 1 -type d -print0)
    done
    
    log "INFO" "Cleaned up ${cleaned} expired cache entries"
}

export_cache() {
    local export_path="${1:-${CACHE_ROOT}/export.tar.gz}"
    
    log "INFO" "Exporting cache to: ${export_path}"
    
    validate_cache all
    
    tar -czf "$export_path" -C "$CACHE_ROOT" . 2>/dev/null || {
        log "ERROR" "Failed to export cache"
        return 1
    }
    
    local export_size
    export_size=$(du -sb "$export_path" 2>/dev/null | cut -f1 || echo "0")
    log "INFO" "Cache exported successfully: $(numfmt --to=iec-i --suffix=B $export_size 2>/dev/null || echo ${export_size}B)"
}

import_cache() {
    local import_path="$1"
    
    if [ ! -f "$import_path" ]; then
        log "ERROR" "Import file does not exist: ${import_path}"
        return 1
    fi
    
    log "INFO" "Importing cache from: ${import_path}"
    
    mkdir -p "$CACHE_ROOT"
    tar -xzf "$import_path" -C "$CACHE_ROOT" 2>/dev/null || {
        log "ERROR" "Failed to import cache"
        return 1
    }
    
    validate_cache all
    log "INFO" "Cache imported successfully"
}

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        init)
            init_cache
            ;;
        store)
            store_cache "$@"
            ;;
        restore)
            restore_cache "$@"
            ;;
        clear)
            clear_cache "$@"
            ;;
        stats)
            show_stats
            ;;
        validate)
            validate_cache "$@"
            ;;
        cleanup)
            cleanup_expired_cache
            ;;
        export)
            export_cache "$@"
            ;;
        import)
            import_cache "$@"
            ;;
        help|*)
            cat << EOF
Cache Management System v${CACHE_VERSION}

Usage: $0 <command> [arguments]

Commands:
  init                    Initialize cache system
  store <type> <src> [id] Store cache from source path
  restore <type> <dst> [id] Restore cache to destination path
  clear [type]            Clear cache (all or specific type)
  stats                   Show cache statistics
  validate [type]         Validate cache entries
  cleanup                 Clean up expired cache entries
  export [path]           Export cache to tarball
  import <path>           Import cache from tarball
  help                    Show this help message

Cache Types:
  dl          Downloaded source packages
  build_dir    Build artifacts
  staging_dir  Toolchain and staging
  tmp          Temporary files
  ccache       Compiler cache
  openwrt      Source tree

Environment Variables:
  CACHE_ROOT           Cache root directory (default: /mnt/cache)
  MAX_CACHE_AGE_DAYS   Maximum cache age in days (default: 7)
  MAX_CACHE_SIZE_GB    Maximum cache size in GB (default: 50)

Examples:
  $0 init
  $0 store dl /workdir/openwrt/dl
  $0 restore dl /workdir/openwrt/dl
  $0 stats
  $0 clear dl
EOF
            ;;
    esac
}

main "$@"
