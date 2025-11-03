#!/usr/bin/env bash

#=============================================================================
# Domain Diagnostics Script
#=============================================================================
# 
# PURPOSE:
#   Automated domain diagnostic tool for network troubleshooting and DNS analysis.
#   Performs comprehensive checks from a local desktop perspective, complementing
#   external web-based diagnostic tools.
#
# DESCRIPTION:
#   This script provides both quick and extended diagnostic capabilities for
#   domain names, automatically detecting available system tools and gracefully
#   falling back when tools are unavailable. Designed for Linux/Unix users
#   working in Windows environments (Git Bash).
#
# FEATURES:
#   • Smart apex/www domain detection and testing
#   • DNS layer analysis (A, AAAA, CNAME, NS, SOA, MX, TXT records)
#   • Network connectivity testing (ping, traceroute)
#   • HTTP/HTTPS analysis with SSL certificate inspection
#   • Tool availability detection with graceful fallbacks
#   • Beautiful TUI using gum for user interactions
#
# DEPENDENCIES:
#   Required:
#     - gum (for interactive prompts and selection)
#   Optional (graceful fallback when missing):
#     - dig (preferred for DNS queries) / nslookup (fallback)
#     - curl (for HTTP/HTTPS testing)
#     - ping (for connectivity testing)
#     - traceroute/tracert (for network path analysis)
#     - openssl (for detailed SSL certificate analysis)
#     - whois (for domain registration info)
#
# USAGE:
#   ./domain_lookup.sh
#   
#   Interactive prompts will guide you through:
#   1. Enter domain name (apex or www)
#   2. Choose to test both apex and www variants
#   3. Select Quick Test or Extended Test level
#
# EXAMPLES:
#   Testing apex domain:     example.com
#   Testing www subdomain:   www.example.com
#   Testing both variants:   Prompted automatically
#
# AUTHOR: Your Name
# VERSION: 1.0
# LAST MODIFIED: November 2025
#
#=============================================================================

# Bash strict mode - exit on errors, undefined variables, and pipe failures
set -euo pipefail

#=============================================================================
# HELPER FUNCTIONS
#=============================================================================

# Check if a diagnostic tool is available on the system
# Usage: has_tool "dig" && echo "dig is available"
has_tool() {
    local tool="$1"
    echo "[DEBUG] has_tool called for: $tool, available_tools: ${available_tools[@]}"
    [[ " ${available_tools[*]} " =~ " $tool " ]]
}

# Check DNS record with consistent output formatting
# Usage: check_dns_record "example.com" "A" "🌐 A Record (IPv4)"
check_dns_record() {
    local domain="$1"
    local record_type="$2" 
    local description="$3"
    
    echo "$description:"
    if has_tool "dig"; then
        local result
        result=$(dig "$domain" "$record_type" +short)
        if [[ -n "$result" ]]; then
            echo "   ✓ Found:"
            echo "$result" | sed 's/^/     • /'
        else
            echo "   ✗ No $record_type record found"
        fi
    else
        echo "   ⚠️  dig not available for $record_type record check"
    fi
}

# Extract apex domain from www subdomain
# Usage: apex=$(get_apex_domain "www.example.com")  # Returns: example.com
get_apex_domain() {
    local domain="$1"
    if [[ $domain == www.* ]]; then
        echo "${domain#www.}"
    else
        echo "$domain"
    fi
}

# Format output with bullet points
# Usage: echo "item1\nitem2" | format_bullets
format_bullets() {
    sed 's/^/     • /'
}

#=============================================================================
# MAIN SCRIPT LOGIC
#=============================================================================

# Step 1: Get target domain from user
# Using gum for beautiful interactive input with placeholder text
host_name=$(gum input --placeholder "Enter a host name (e.g., example.com)")

echo "Performing diagnostics for host: $host_name"

# Step 2: Choose diagnostic complexity level
# Quick test covers essentials, Extended test includes advanced analysis
echo "Choose diagnostic level:"
test_level=$(gum choose \
  "Quick Test (DNS + Basic connectivity)" \
  "Extended Test (Full diagnostic suite)"
)

# Step 3: Smart domain variant detection and selection
# Many issues occur due to differences between apex and www behavior
# This logic automatically detects what the user entered and offers to test both variants

if [[ $host_name == www.* ]]; then
    # User entered www subdomain - extract apex domain and offer to test it
    apex_domain=${host_name#www.}  # Bash parameter expansion to remove 'www.' prefix
    echo "You entered a www domain. Do you also want to test the apex domain?"
    test_apex=$(gum choose "Yes, also test $apex_domain" "No, only test $host_name")
    
    # Build domains list based on user choice
    if [[ $test_apex == "Yes"* ]]; then
        domains="$host_name\n$apex_domain"  # Test both www and apex
    else
        domains="$host_name"  # Test only www
    fi
else
    # User entered apex domain - offer to also test www subdomain
    echo "Do you also want to test the www subdomain?"
    test_www=$(gum choose "Yes, also test www.$host_name" "No, only test $host_name")
    
    # Build domains list based on user choice  
    if [[ $test_www == "Yes"* ]]; then
        domains="$host_name\nwww.$host_name"  # Test both apex and www
    else
        domains="$host_name"  # Test only apex
    fi
fi

# show summary of what we're about to do
echo ""
echo "=== Summary of Selected Diagnostics ==="
echo "Original host entered: $host_name"

echo ""
echo "Domains to test:"
echo -e "$domains" | while read -r domain; do
    if [[ -n "$domain" ]]; then
        echo "  • $domain"
    fi
done

echo ""
echo "Test level selected: $test_level"

if [[ $test_level == "Quick Test"* ]]; then
    echo "Quick test includes:"
    echo "  • DNS analysis (A, AAAA, CNAME, NS, SOA, MX records)"
    echo "  • Basic connectivity test (ping)"
    echo "  • HTTP/HTTPS response headers"
else
    echo "Extended test includes:"
    echo "  • DNS analysis (A, AAAA, CNAME, NS, SOA, MX, TXT records)"
    echo "  • Connectivity tests (ping, traceroute if available)"
    echo "  • HTTP/HTTPS detailed analysis"
    echo "  • SSL/TLS certificate information"
    echo "  • Additional network diagnostics"
fi

# check what diagnostic tools are available on this system
echo "=== Checking Available Tools ==="
declare -g -a available_tools=()

# check for common diagnostic tools
tools_to_check=("ping" "nslookup" "dig" "curl" "host" "openssl" "telnet" "nc" "nmap" "whois" "traceroute" "tracert")

for tool in "${tools_to_check[@]}"; do
    if command -v "$tool" &> /dev/null; then
        available_tools+=("$tool")
        echo "  ✓ $tool is available"
    else
        echo "  ✗ $tool is not available"
    fi
    # End of tool detection loop

done

echo "[DEBUG] available_tools after detection: ${available_tools[@]}"

echo ""
echo "Ready to begin diagnostics..."
echo ""

# define functions for each test type
run_dns_analysis() {
    local domain=$1
    local extended=$2
    
    # determine apex domain for NS/SOA checks
    if [[ $domain == www.* ]]; then
        apex_for_dns=${domain#www.}
    else
        apex_for_dns="$domain"
    fi
    
    echo "📋 DNS Layer Analysis for $domain"
    echo "   (Essential records in order of importance)"
    echo ""
    
    # Use dig if available, otherwise nslookup with cleaner output
    if has_tool "dig"; then
        # 1. SOA Record (Start of Authority) - shows primary DNS server and zone info
        if [[ "$domain" == "$apex_for_dns" ]]; then
            echo "�️  SOA Record (Start of Authority for $apex_for_dns):"
            soa_result=$(dig "$apex_for_dns" SOA +short)
            if [[ -n "$soa_result" ]]; then
                echo "   ✓ Found: $soa_result"
            else
                echo "   ✗ No SOA record found"
            fi
            echo ""
            
            # 2. NS Records (Name Servers) - shows authoritative DNS servers
            echo "�️  NS Records (Authoritative Name Servers for $apex_for_dns):"
            ns_result=$(dig "$apex_for_dns" NS +short)
            if [[ -n "$ns_result" ]]; then
                echo "   ✓ Authoritative name servers:"
                echo "$ns_result" | format_bullets
            else
                echo "   ✗ No NS records found"
            fi
            echo ""
        else
            # For subdomains, still check apex SOA/NS for context
            echo "🏛️  Domain Authority (checking apex: $apex_for_dns):"
            soa_result=$(dig "$apex_for_dns" SOA +short)
            ns_result=$(dig "$apex_for_dns" NS +short)
            if [[ -n "$soa_result" ]] && [[ -n "$ns_result" ]]; then
                echo "   ✓ Apex domain has proper DNS delegation"
                echo "   Primary NS: $(echo "$ns_result" | head -1)"
            else
                echo "   ⚠️  Issues with apex domain DNS delegation"
            fi
            echo ""
        fi
        
        # 3. A Record (IPv4 address) - the most common record type
        echo "� A Record (IPv4 Address for $domain):"
        a_result=$(dig "$domain" A +short)
        if [[ -n "$a_result" ]]; then
            echo "   ✓ Found:"
            echo "$a_result" | format_bullets
        else
            echo "   ✗ No A record found"
        fi
        echo ""
        
        # 4. CNAME Record (Canonical Name) - common for subdomains like www
        echo "🔗 CNAME Record (Alias for $domain):"
        cname_result=$(dig "$domain" CNAME +short)
        if [[ -n "$cname_result" ]]; then
            echo "   ✓ Found: $cname_result"
            echo "   ℹ️  This domain is an alias pointing to the canonical name above"
        else
            echo "   ✗ No CNAME record found (normal for apex domains)"
        fi
        
    elif has_tool "nslookup"; then
        echo "🔧 Using nslookup (dig not available)"
        echo ""
        
        # 1. SOA Record for apex domain
        if [[ "$domain" == "$apex_for_dns" ]]; then
            echo "🏛️  SOA Record (Start of Authority):"
            soa_output=$(nslookup -type=SOA "$apex_for_dns" 2>/dev/null | grep -E "(primary name server|responsible mail addr|serial|refresh|retry|expire|minimum)")
            if [[ -n "$soa_output" ]]; then
                echo "   ✓ Found SOA record"
                echo "$soa_output" | sed 's/^/     /'
            else
                echo "   ✗ No SOA record found"
            fi
            echo ""
            
            # 2. NS Records  
            echo "🏛️  NS Records (Name Servers):"
            ns_output=$(nslookup -type=NS "$apex_for_dns" 2>/dev/null | grep "nameserver" | awk '{print $4}')
            if [[ -n "$ns_output" ]]; then
                echo "   ✓ Found name servers:"
                echo "$ns_output" | format_bullets
            else
                echo "   ✗ No NS records found"
            fi
            echo ""
        fi
        
        # 3. A Record
        echo "🌐 A Record (IPv4 Address):"
        a_output=$(nslookup "$domain" 2>/dev/null | grep "Address:" | grep -v "#53" | awk '{print $2}')
        if [[ -n "$a_output" ]]; then
            echo "   ✓ Found:"
            echo "$a_output" | format_bullets
        else
            echo "   ✗ No A record found"
        fi
        echo ""
        
        # 4. CNAME Record (only if no A record found)
        if [[ -z "$a_output" ]]; then
            echo "🔗 CNAME Record (checking for alias):"
            cname_output=$(nslookup "$domain" 2>/dev/null | grep "canonical name" | awk '{print $4}')
            if [[ -n "$cname_output" ]]; then
                echo "   ✓ Found: $cname_output"
            else
                echo "   ✗ No CNAME record found"
            fi
        fi
        
    else
        echo "❌ Neither dig nor nslookup available for DNS analysis"
        echo "   Skipping DNS analysis for $domain. Please install dig or nslookup."
        return 0
    fi
    
    # Add informational note about additional record types
    echo ""
    echo "💡 Additional DNS Records Worth Checking:"
    echo "   • MX (Mail Exchange) - for email routing"
    echo "   • TXT (Text) - for SPF, DKIM, domain verification"
    echo "   • AAAA (IPv6) - for IPv6 addresses"
    echo "   • CAA (Certificate Authority Authorization) - for SSL certificate control"
    echo "   • SRV (Service) - for service discovery"
    echo "   💡 Use 'dig $apex_for_dns [record_type]' or external tools for detailed analysis"
}

run_connectivity_test() {
    local domain=$1
    local extended=$2
    
    echo "🔌 Connectivity Analysis for $domain"
    echo ""
    
    # Ping test with cross-platform compatibility
    if has_tool "ping"; then
        echo "📡 Ping Test:"
        # Windows ping uses -n, Unix/Linux uses -c
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || command -v cmd.exe &> /dev/null; then
            # Windows environment (Git Bash, Cygwin, etc.)
            ping -n 4 "$domain" || echo "   ✗ Ping failed for $domain"
        else
            # Unix/Linux environment
            ping -c 4 "$domain" || echo "   ✗ Ping failed for $domain"
        fi
    else
        echo "📡 Ping tool not available"
    fi
    
    # Traceroute (extended only)
    if [[ "$extended" == "true" ]]; then
        echo ""
        if [[ " ${available_tools[*]} " =~ " traceroute " ]]; then
            echo "🗺️  Traceroute:"
            traceroute "$domain" || echo "   ✗ Traceroute failed"
        elif [[ " ${available_tools[*]} " =~ " tracert " ]]; then
            echo "🗺️  Tracert (Windows):"
            tracert "$domain" || echo "   ✗ Tracert failed"
        else
            echo "🗺️  Traceroute tool not available"
        fi
    fi
}

run_http_analysis() {
    local domain=$1
    local extended=$2
    
    echo "🌐 HTTP/HTTPS Analysis for $domain"
    echo ""
    
    if [[ " ${available_tools[*]} " =~ " curl " ]]; then
        # HTTP test
        echo "🔓 HTTP Response:"
        curl -I -L --connect-timeout 10 "http://$domain" || echo "   ✗ HTTP request failed for $domain"
        
        echo ""
        echo "🔒 HTTPS Response:"
        curl -I -L --connect-timeout 10 "https://$domain" || echo "   ✗ HTTPS request failed for $domain"
        
        # Extended HTTPS analysis
        if [[ "$extended" == "true" ]]; then
            echo ""
            echo "🔐 SSL/TLS Certificate Information:"
            if [[ " ${available_tools[*]} " =~ " openssl " ]]; then
                echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -text | head -20 || echo "   ✗ SSL certificate analysis failed"
            else
                curl -vI --connect-timeout 10 "https://$domain" 2>&1 | grep -E "(SSL|TLS|certificate)" || echo "   ✗ SSL analysis with curl failed"
            fi
        fi
    else
        echo "Curl tool not available for HTTP/HTTPS analysis"
    fi
}

declare -a summary_rows

# Table header
summary_rows+=("Domain	SOA	NS	A	CNAME	Ping	HTTP	HTTPS")

# main diagnostic execution
IFS=$'\n'
for domain in $domains; do
    if [[ -n "$domain" ]]; then
        echo "========================================"
        echo "Testing domain: $domain"
        echo "========================================"

        is_extended="false"
        if [[ $test_level == "Extended Test"* ]]; then
            is_extended="true"
        fi

        # DEBUG: Print current domain and test level
        echo "[DEBUG] domain: $domain"
        echo "[DEBUG] is_extended: $is_extended"

        # Collect results for summary table
        # DNS
        apex_for_dns=$(get_apex_domain "$domain")
        echo "[DEBUG] apex_for_dns: $apex_for_dns"
        soa_result="-"
        ns_result="-"
        a_result="-"
        cname_result="-"

        if has_tool "dig"; then
            soa_result=$(dig "$apex_for_dns" SOA +short | head -1 || true)
            ns_result=$(dig "$apex_for_dns" NS +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
            a_result=$(dig "$domain" A +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
            cname_result=$(dig "$domain" CNAME +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
        elif has_tool "nslookup"; then
            soa_result=$(nslookup -type=SOA "$apex_for_dns" 2>/dev/null | grep -E "primary name server" | awk '{print $4}' || true)
            ns_result=$(nslookup -type=NS "$apex_for_dns" 2>/dev/null | grep "nameserver" | awk '{print $4}' | tr '\n' ',' | sed 's/,$//' || true)
            a_result=$(nslookup "$domain" 2>/dev/null | grep "Address:" | grep -v "#53" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//' || true)
            cname_result=$(nslookup "$domain" 2>/dev/null | grep "canonical name" | awk '{print $4}' | tr '\n' ',' | sed 's/,$//' || true)
        fi
        echo "[DEBUG] soa_result: $soa_result"
        echo "[DEBUG] ns_result: $ns_result"
        echo "[DEBUG] a_result: $a_result"
        echo "[DEBUG] cname_result: $cname_result"
        [[ -z "$soa_result" ]] && soa_result="-"
        [[ -z "$ns_result" ]] && ns_result="-"
        [[ -z "$a_result" ]] && a_result="-"
        [[ -z "$cname_result" ]] && cname_result="-"

        # Ping
        ping_result="-"
        if has_tool "ping"; then
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || command -v cmd.exe &> /dev/null; then
                ping -n 1 "$domain" &> /dev/null && ping_result="OK" || ping_result="Fail"
            else
                ping -c 1 "$domain" &> /dev/null && ping_result="OK" || ping_result="Fail"
            fi
        fi
        echo "[DEBUG] ping_result: $ping_result"

        # HTTP/HTTPS
        http_result="-"
        https_result="-"
        if has_tool "curl"; then
            curl -I --connect-timeout 5 "http://$domain" 2>/dev/null | grep -q "200\|301\|302" && http_result="OK" || http_result="Fail"
            curl -I --connect-timeout 5 "https://$domain" 2>/dev/null | grep -q "200\|301\|302" && https_result="OK" || https_result="Fail"
        fi
        echo "[DEBUG] http_result: $http_result"
        echo "[DEBUG] https_result: $https_result"

        # Add row to summary
        summary_rows+=("$domain\t$soa_result\t$ns_result\t$a_result\t$cname_result\t$ping_result\t$http_result\t$https_result")

        # ...existing code...
        run_dns_analysis "$domain" "$is_extended"
        echo ""
        run_connectivity_test "$domain" "$is_extended"
        echo ""
        run_http_analysis "$domain" "$is_extended"
        echo ""
        echo "========================================"
        echo ""
    fi
done
unset IFS

# Show summary table (non-interactive)
echo ""
echo "=== Summary Table ==="
if command -v column &> /dev/null; then
    printf "%s\n" "${summary_rows[@]}" | column -t -s $'\t'
else
    printf "%s\n" "${summary_rows[@]}"
fi

# #=============================================================================
# # EXTERNAL DIAGNOSTIC TOOLS (Web-based) - COMMENTED OUT FOR NOW
# #=============================================================================
# # 
# # The local diagnostics above show the view from your current network/location.
# # External tools provide the "public internet" perspective and additional insights
# # that complement local testing.
# # 
# # TODO: Uncomment and enhance this section later for browser-based external tools
# # including: whatsmydns.net, digwebinterface.com, ipinfo.io, whois.net,
# # reqbin.com, ssllabs.com, etc.

# echo "║ domain analysis.                                                           ║"
# echo "╚════════════════════════════════════════════════════════════════════════════╝"
# echo ""

# # Ask if user wants to launch external tools
# echo "Would you like to open external diagnostic tools in your browser?"
# launch_external=$(gum choose \
#   "Yes, show me external tools" \
#   "No, I'm done with diagnostics"
# )

# if [[ $launch_external == "Yes"* ]]; then
#     # Get the primary domain for external checks (use apex domain)
#     primary_domain=$(get_apex_domain "$host_name")
#     
#     echo ""
#     echo "🌐 External Tools for: $primary_domain"
#     echo "   (Press Enter after each prompt to launch in browser)"
#     echo ""
#     
#     # DNS Propagation and Global View
#     echo "📡 DNS Propagation Check (whatsmydns.net):"
#     echo "   Check DNS records from multiple global locations"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://whatsmydns.net/#A/$primary_domain" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://whatsmydns.net/#A/$primary_domain" 2>/dev/null &
#     fi
#     echo ""
#     
#     # Web-based DNS Interface
#     echo "🔍 Web DNS Interface (digwebinterface.com):"
#     echo "   Comprehensive DNS record lookup with global perspective"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://digwebinterface.com/?hostnames=$primary_domain&type=ANY&ns=resolver&useresolver=8.8.4.4" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://digwebinterface.com/?hostnames=$primary_domain&type=ANY&ns=resolver&useresolver=8.8.4.4" 2>/dev/null &
#     fi
#     echo ""
#     
#     # IP and Geolocation Info
#     echo "🗺️  IP Information (ipinfo.io):"
#     echo "   Get IP geolocation, ASN, and network details"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://ipinfo.io/$primary_domain" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://ipinfo.io/$primary_domain" 2>/dev/null &
#     fi
#     echo ""
#     
#     # WHOIS/RDAP Information
#     echo "📋 Domain Registration Info (whois.net):"
#     echo "   Check domain registration, registrar, and RDAP data"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://www.whois.net/whois/$primary_domain" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://www.whois.net/whois/$primary_domain" 2>/dev/null &
#     fi
#     echo ""
#     
#     # HTTP/HTTPS Testing
#     echo "🌐 HTTP Request Testing (reqbin.com):"
#     echo "   Test HTTP/HTTPS requests with detailed response analysis"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://reqbin.com/curl" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://reqbin.com/curl" 2>/dev/null &
#     fi
#     echo "   Manual step: Enter 'https://$primary_domain' in the URL field"
#     echo ""
#     
#     # SSL Certificate Analysis  
#     echo "🔒 SSL Certificate Analysis (ssllabs.com):"
#     echo "   Comprehensive SSL/TLS security assessment"
#     read -p "   Press Enter to open → " -r
#     if command -v explorer.exe &> /dev/null; then
#         explorer.exe "https://www.ssllabs.com/ssltest/analyze.html?d=$primary_domain" 2>/dev/null &
#     elif command -v xdg-open &> /dev/null; then
#         xdg-open "https://www.ssllabs.com/ssltest/analyze.html?d=$primary_domain" 2>/dev/null &
#     fi
#     echo ""
#     
#     echo "✅ External diagnostic tools have been launched in your browser!"
#     echo "   These provide the 'external perspective' to complement your local tests."
# else
#     echo ""
#     echo "✅ Local diagnostics complete!"
# fi

echo ""
echo "🎉 Domain diagnostic session finished for: $host_name"
# echo "   Remember: Local tests show YOUR perspective, external tools show the world's view!"

