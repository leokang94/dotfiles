###############################
# AI API KEY MANAGEMENT
###############################

# Define array of API keys to manage (centralized definition)
AI_API_KEYS=("OPENAI_API_KEY" "ANTHROPIC_API_KEY" "TAVILY_API_KEY")

# Setup cache directory
CACHE_DIR="$HOME/.cache"
AI_KEYS_CACHE="$CACHE_DIR/ai-api-keys.txt"
[ ! -d "$CACHE_DIR" ] && mkdir -p "$CACHE_DIR"
[ ! -f "$AI_KEYS_CACHE" ] && touch "$AI_KEYS_CACHE" && chmod 600 "$AI_KEYS_CACHE"

# Function to get key from cache file
get_cached_key() {
  local key_name="$1"
  grep "^${key_name}=" "$AI_KEYS_CACHE" | cut -d'=' -f2
}

# Function to set key in cache file
set_cached_key() {
  local key_name="$1"
  local key_value="$2"
  # Remove existing line if exists
  sed -i '' "/^${key_name}=/d" "$AI_KEYS_CACHE"
  # Append new key
  echo "${key_name}=${key_value}" >> "$AI_KEYS_CACHE"
}

# Function to fetch API key from 1Password and update cache
fetch_and_cache_key() {
  local key_name="$1"
  local force_update="${2:-false}"
  local key_value=""
  
  # Get from cache first unless force update is requested
  if [[ "$force_update" != "true" ]]; then
    key_value=$(get_cached_key "$key_name")
  fi
  
  # If not in cache or force update, get from 1Password
  if [[ -z "$key_value" || "$force_update" == "true" ]]; then
    if command -v op &> /dev/null; then
      key_value=$(op item get "$key_name" --reveal --vault ZSH --fields label=password)
      # Cache the key if successfully retrieved
      [[ ! -z "$key_value" ]] && set_cached_key "$key_name" "$key_value"
    fi
  fi
  
  echo "$key_value"
}

# Function to load all API keys
load_api_keys() {
  local force_update="${1:-false}"
  
  if command -v op &> /dev/null; then
    for key_name in "${AI_API_KEYS[@]}"; do
      local key_value=$(fetch_and_cache_key "$key_name" "$force_update")
      # Export the key to environment
      [[ ! -z "$key_value" ]] && export "$key_name"="$key_value"
    done
  fi
}

