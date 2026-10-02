# Chaincode Install Failure: Docker API Version Mismatch

## Symptom

`./network.sh deployCC` (or a bare `peer lifecycle chaincode install`) fails at the
install step with:

```
Error: chaincode install failed with status: 500 - failed to invoke backing
implementation of 'InstallChaincode': could not build chaincode: docker build
failed: docker image build failed: write unix @->/run/docker.sock: write: broken pipe
```

Everything before this step (network up, channel create, peers joining) works fine.
The failure is consistent/reproducible, not a one-off — retrying, pruning the build
cache, or restarting the peer containers does not fix it.

## Root Cause

Fabric's `peer` binary builds chaincode Docker images itself by talking directly to
the host's Docker Engine API over `/run/docker.sock` (via `CORE_VM_ENDPOINT`). The
`peer` binary (built for Fabric 2.5.x) ships a Docker API client that defaults to an
**old** API version.

Modern Docker Engine releases enforce a `MinAPIVersion` and hard-reject any client
that asks for something older — the daemon accepts the request headers, decides the
version is too old, and closes the connection **while the peer is still streaming
the chaincode's tar build context** to it. From the peer's side, that abrupt close
during upload looks exactly like `write: broken pipe`.

You can confirm this is the cause by checking the daemon's minimum supported version:

```bash
curl -s --unix-socket /run/docker.sock http://localhost/version | python3 -m json.tool
# Look at "MinAPIVersion" — e.g. "1.44"
```

and confirming a plain `docker build` (via the CLI, which auto-negotiates a modern
API version) succeeds fine even though the peer's internal build call fails — that
asymmetry is the signature of this bug. It shows up whenever the host's Docker Engine
gets upgraded to a version whose `MinAPIVersion` has climbed past what Fabric 2.5's
peer binary speaks.

### Things that do **NOT** fix it (already ruled out)

- Restarting Docker, the peer containers, or the whole network.
- `docker builder prune` / clearing the build cache.
- Setting `DOCKER_API_VERSION` as an env var on the peer container — Fabric's peer
  binary does not appear to honor this standard Docker client env var.
- Disk space, memory, or cgroup limits — none were the bottleneck when this was
  diagnosed (verify with `df -h`, `free -h`, `docker system df` if you want to rule
  these out again before assuming it's the same root cause).

## Fix: Pin the host's Docker Engine to an older version

The only working fix found: install an older `docker-ce` build (one with a low
`MinAPIVersion`) from Docker's **official** apt repo, instead of the distro's bundled
`docker.io` package (which only ever has the latest version available).

> ⚠️ This changes the Docker Engine for the **entire host**, not just this project.
> It stops every running container while `docker.service` restarts. Check
> `docker ps` first and make sure nothing unrelated and important is running before
> you do this on a shared machine.

### 1. Stop the Fabric network cleanly

```bash
cd ~/fabric-samples-TC/test-network
./network.sh down
```

### 2. Remove the distro Docker package, add Docker's official repo

```bash
sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### 3. Install a pinned, older docker-ce build and hold it

Find the oldest version available for your Ubuntu codename (older = lower, more
permissive `MinAPIVersion`):

```bash
apt-cache madison docker-ce | sort -V
```

Install a specific old version (this example uses `26.0.0`, the oldest build
available for Ubuntu 24.04/"noble" — 24.x/25.x builds don't exist for noble since
they predate that Ubuntu release):

```bash
sudo apt-get install -y docker-ce=5:26.0.0-1~ubuntu.24.04~noble \
  docker-ce-cli=5:26.0.0-1~ubuntu.24.04~noble \
  containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-mark hold docker-ce docker-ce-cli
```

**If this step fails with a `dpkg` error about overwriting
`/usr/libexec/docker/cli-plugins/docker-compose`**, it's a conflict between the
official `docker-compose-plugin` and Ubuntu's `docker-compose-v2` package (both ship
the same file). `dpkg` aborts the whole batch before it configures anything, so the
new `docker-ce` never actually gets started. Fix:

```bash
sudo apt-get remove -y docker-compose-v2
sudo dpkg --configure -a
sudo apt-get install -y docker-ce=5:26.0.0-1~ubuntu.24.04~noble \
  docker-ce-cli=5:26.0.0-1~ubuntu.24.04~noble \
  containerd.io docker-buildx-plugin docker-compose-plugin
```

### 4. If `docker version` says "Cannot connect to the Docker daemon"

Check `sudo systemctl status docker.service --no-pager -l`. If you see:

```
failed to load listeners: no sockets found via socket activation:
make sure the service was started by systemd
```

systemd is holding stale unit definitions from before the package swap (it needs a
reload after `docker-ce` replaced the unit files). Fix:

```bash
sudo systemctl daemon-reload
sudo systemctl stop docker.service docker.socket
sudo systemctl start docker.socket
sudo systemctl start docker.service
```

### 5. Verify and redeploy

```bash
docker version --format 'Server MinAPIVersion: {{.Server.MinAPIVersion}}, Version: {{.Server.Version}}'
# Should print something like: Server MinAPIVersion: 1.24, Version: 26.0.0

cd ~/fabric-samples-TC/test-network
./network.sh up createChannel -c mychannel -ca
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript -ccl typescript
```

## Preventing this from recurring

- `docker-ce` and `docker-ce-cli` are held (`apt-mark hold`), so routine
  `apt upgrade` won't silently bump Docker back to an incompatible version. Don't
  `apt-mark unhold` them on this host without expecting this problem to come back.
- If you ever need to intentionally upgrade Docker on this host, re-check
  `MinAPIVersion` against a working chaincode install *before* trusting it in this
  project — don't assume a newer Docker Engine is safe for Fabric 2.5.x.
- Longer-term, the durable fix is to stop relying on Fabric's built-in Docker
  chaincode builder entirely and switch to **Chaincode-as-a-Service (CCaaS)**, where
  you build/run the chaincode container yourself with a normal `docker build`/
  `docker run` (which always negotiates a modern API version correctly) and the peer
  only connects to it over gRPC — it never calls the Docker API itself. This sidesteps
  the whole class of problem regardless of what Docker Engine version the host runs.
