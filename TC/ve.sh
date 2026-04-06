import asyncio, socket, struct, random, aiohttp

TARGET_PORT = 8317
CONCURRENCY = 3000
TIMEOUT_HTTP = 3.5
OUTPUT_FILE = "1panel.backup.log"

async def verify_http(ip, session, semaphore ):
    async with semaphore:
        url = f"http://{ip}:{TARGET_PORT}"
        try:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=TIMEOUT_HTTP )) as resp:
                with open(OUTPUT_FILE, "a") as f:
                    f.write(f"{url}\n")
                print(f"[+] ok: {url}")
        except:
            pass

def ip_gen_all():
    while True:
        ip_int = random.getrandbits(32)
        ip = socket.inet_ntoa(struct.pack('>I', ip_int))
        if not ip.startswith(("10.", "127.", "169.254.", "172.16.", "172.17.", "172.18.", 
                              "172.19.", "172.20.", "172.21.", "172.22.", "172.23.", 
                              "172.24.", "172.25.", "172.26.", "172.27.", "172.28.", 
                              "172.29.", "172.30.", "172.31.", "192.168.", "224.", "240.")):
            yield ip

async def main():
    semaphore = asyncio.Semaphore(CONCURRENCY)
    tasks = []
    gen = ip_gen_all()

    connector = aiohttp.TCPConnector(limit=0, ttl_dns_cache=300 )
    async with aiohttp.ClientSession(connector=connector ) as session:
        while True:
            while len(tasks) < CONCURRENCY * 1.5:
                tasks.append(asyncio.create_task(verify_http(next(gen ), session, semaphore)))

            done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
            tasks = list(pending)

if __name__ == "__main__":
    try:
        import resource
        resource.setrlimit(resource.RLIMIT_NOFILE, (65535, 65535))
    except: pass
    asyncio.run(main())
