# Domain diagnostics checklist

Generated: $(date --iso-8601=seconds 2>/dev/null || date)

## $host

 - [x] A record: \\`$a\\`
 - [x] AAAA record: \\`$aaaa\\`
 - [ ] CNAME: \\`$cname\\`
 - [x] NS: \\`$ns\\`
 - [x] SOA: \\`$soa\\`
 - [ ] WHOIS (registrar/org): \\`$whois_summary\\`
 - [x] Ping: \\`$ping_res\\`
 - [x] HTTP: \\`$(echo "$http_res" | cut -d'|' -f1)\\` HTTPS: [x] \\`$(echo "$http_res" | cut -d'|' -f2)\\`

