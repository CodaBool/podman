# Test run: hardening changes

Run each step in your SSH console on the server, in order, then paste the output into the matching box in the **Results** form at the bottom.

What changed: uptime, tunnel and syncthing are pinned to versions. webtop and brave dropped `SecurityLabelDisable` and bind ports to `127.0.0.1`. syncthing left `Network=host` for `PublishPort`.

> Restarting `tunnel` briefly cuts Cloudflare access. Restarting `webtop` and `brave` ends any desktop session or ralph loop running in them.

## 1. Pull and validate

```bash
cd ~/.config/containers/systemd && git pull && git log --oneline -5 && git status --short
```

```bash
/usr/libexec/podman/quadlet -dryrun -user 2>&1 | grep -v 'permission denied' | grep -iE 'error|warn|^---(syncthing|uptime|tunnel|webtop|brave)'
systemctl --user daemon-reload && echo reloaded
```

## 2. SELinux and GPU device state (before restarting)

```bash
getenforce
getsebool container_use_devices
ls -lZ /dev/dri /dev/kfd
```

## 3. Syncthing, uptime and tunnel

```bash
systemctl --user restart syncthing uptime
sleep 20
podman ps --filter name=syncthing --filter name=uptime --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
ss -tlnup | grep -E ':(8384|22000|3001) '
curl -sI -m 5 http://127.0.0.1:8384 | head -1
curl -sI -m 5 http://127.0.0.1:3001 | head -1
```

```bash
systemctl --user restart tunnel
sleep 15
podman ps --filter name=tunnel --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
journalctl --user -u tunnel -n 15 --no-pager
```

## 4. webtop

```bash
systemctl --user restart webtop
sleep 45
systemctl --user is-active webtop
podman ps --filter name=webtop --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
podman inspect webtop --format 'SecurityOpt={{.HostConfig.SecurityOpt}}'
curl -sI -m 5 http://127.0.0.1:8669 | head -1
```

```bash
podman exec --user abc webtop sh -c 'for d in /dev/kfd /dev/dri/renderD128; do [ -r $d ] && [ -w $d ] && echo "$d rw ok" || echo "$d NO ACCESS"; done'
```

```bash
journalctl --user -u webtop -n 25 --no-pager
sudo ausearch -m avc,user_avc -ts recent 2>&1 | tail -20
```

## 5. brave

```bash
systemctl --user restart brave
sleep 45
systemctl --user is-active brave
podman ps --filter name=brave --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
podman inspect brave --format 'SecurityOpt={{.HostConfig.SecurityOpt}}'
curl -sI -m 5 http://127.0.0.1:8670 | head -1
curl -sI -m 5 http://127.0.0.1:9119 | head -1
```

```bash
podman exec --user abc brave sh -c 'for d in /dev/kfd /dev/dri/renderD128; do [ -r $d ] && [ -w $d ] && echo "$d rw ok" || echo "$d NO ACCESS"; done'
```

```bash
journalctl --user -u brave -n 25 --no-pager
sudo ausearch -m avc,user_avc -ts recent 2>&1 | tail -20
```

## 6. Loopback binding check

These should **fail**: the ports are now loopback only, so the LAN address gets no answer.

```bash
for p in 8669 8670 9119 8642; do printf "%s via LAN IP: " $p; curl -s -o /dev/null -m 3 -w '%{http_code}\n' http://192.168.0.25:$p || echo "refused or timed out (expected)"; done
```

## 7. Only if the GPU or start-up failed with an SELinux denial in step 4 or 5

Skip this if both services started and the GPU check said `rw ok`.

```bash
sudo setsebool -P container_use_devices 1 && getsebool container_use_devices
systemctl --user restart webtop brave
```

## 8. Final summary

```bash
systemctl --user --failed --no-pager
podman ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

---

# Results

Paste the output under each heading and mark the result.

### 1. Pull and validate
Result: [ ] pass  [ ] fail

```text

```

### 2. SELinux and GPU device state
Result: [ ] pass  [ ] fail

```text

```

### 3a. Syncthing and uptime
Result: [ ] pass  [ ] fail

```text

```

### 3b. Tunnel
Result: [ ] pass  [ ] fail

```text

```

### 4a. webtop status
Result: [ ] pass  [ ] fail

```text

```

### 4b. webtop GPU access
Result: [ ] pass  [ ] fail

```text

```

### 4c. webtop logs and AVC denials
Result: [ ] pass  [ ] fail

```text

```

### 5a. brave status
Result: [ ] pass  [ ] fail

```text

```

### 5b. brave GPU access
Result: [ ] pass  [ ] fail

```text

```

### 5c. brave logs and AVC denials
Result: [ ] pass  [ ] fail

```text

```

### 6. Loopback binding check
Result: [ ] pass  [ ] fail

```text

```

### 7. setsebool (only if needed)
Result: [ ] skipped  [ ] pass  [ ] fail

```text

```

### 8. Final summary
Result: [ ] pass  [ ] fail

```text

```

### Notes
Anything that looked wrong, or that you want me to look at:

```text

```
