#!/usr/bin/env bash

# Interactive domain lookup script with Markdown export support

# Function to check for required commands
dependency_check() {
  if ! command -v dig &>/dev/null && ! command -v nslookup &>/dev/null; then
    echo "Error: Neither 'dig' nor 'nslookup' is installed. Please install one of them and try again." >&2
    exit 1
  fi
}

# Function to perform interactive domain lookup
interactive_lookup() {
  dependency_check

  echo "Welcome to the Interactive Domain Lookup!"
  read -p "Enter a domain to analyze: " domain

  echo "Analyzing domain: $domain"
  echo "Fetching DNS records..."
  if command -v dig &>/dev/null; then
    dig +short "$domain"
  else
    nslookup "$domain"
  fi

  echo "Performing WHOIS lookup..."
  if command -v whois &>/dev/null; then
    whois "$domain"
  else
    echo "WHOIS lookup skipped: 'whois' is not installed."
  fi

  echo "Interactive analysis complete."
}

if [[ "${1:-}" == "--export-md" ]]; then
  domain="$2"
  outfile="$3"
  echo "# Interactive Domain Lookup Report\n\n- Host: $domain" > "$outfile"
  echo "Markdown export created at $outfile"
else
  interactive_lookup
fi