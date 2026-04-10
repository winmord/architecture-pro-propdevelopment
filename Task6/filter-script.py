import json
import re

INPUT_LOG = "audit.log"
OUTPUT_FILE = "audit-extract.json"

suspicious_events = []

with open(INPUT_LOG, "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            if re.search(r"audit-policy", line, re.IGNORECASE):
                suspicious_events.append({"raw_line": line})
            continue

        verb = event.get("verb")
        resource = event.get("objectRef", {}).get("resource")
        subresource = event.get("objectRef", {}).get("subresource")

        if resource == "secrets" and verb == "get":
            suspicious_events.append(event)
        elif verb == "create" and subresource == "exec":
            suspicious_events.append(event)
        elif resource == "pods" and verb == "create":
            containers = event.get("requestObject", {}).get("spec", {}).get("containers", [])
            if any(c.get("securityContext", {}).get("privileged", False) for c in containers):
                suspicious_events.append(event)
        elif re.search(r"audit-policy", json.dumps(event), re.IGNORECASE):
            suspicious_events.append(event)

with open(OUTPUT_FILE, "w") as f:
    json.dump(suspicious_events, f, indent=2)

print(f"[+] Найдено {len(suspicious_events)} подозрительных событий")