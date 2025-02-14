# Setup AI API Keys on login
# 1password cli must be installed and configured
if command -v op &> /dev/null; then
  export OPENAI_API_KEY=$(op item get OPENAI_API_KEY --reveal --vault ZSH --fields label=password)
  export ANTHROPIC_API_KEY=$(op item get ANTHROPIC_API_KEY --reveal --vault ZSH --fields label=password)
fi

