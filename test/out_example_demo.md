# Domain diagnostics checklist (example)

Generated: 2025-11-03T00:00:00Z

## example.com

- [x] A record: `93.184.216.34`
- [ ] AAAA record: `-`
- [ ] CNAME: `-`
- [x] NS: `a.iana-servers.net, b.iana-servers.net`
- [x] SOA: `ns.icann.org`
- [x] WHOIS (registrar/org): `Internet Assigned Numbers Authority`
- [x] Ping: `OK`
- [x] HTTP: `OK` HTTPS: `OK`

Notes:
- This file is an example checklist used for demos. To generate a live checklist, run:

```bash
./domain_lookup_min.sh --host example.com --output-md out.md
```
