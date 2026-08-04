#!/usr/bin/env python3
"""Send UDP test payloads to the Nexys UDP echo stack."""

from __future__ import annotations

import argparse
import socket


def main() -> None:
    p = argparse.ArgumentParser(description="Send UDP echo test to Nexys A7")
    p.add_argument("--host", default="255.255.255.255")
    p.add_argument("--port", type=int, default=50000)
    p.add_argument("--payload", default="echo-test")
    p.add_argument("--repeat", type=int, default=1)
    args = p.parse_args()

    payload = args.payload.encode()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.settimeout(2.0)

    for i in range(args.repeat):
        sock.sendto(payload, (args.host, args.port))
        print(f"Sent {len(payload)} bytes to {args.host}:{args.port}")
        try:
            data, addr = sock.recvfrom(2048)
            print(f"Reply {len(data)} bytes from {addr}: {data!r}")
        except socket.timeout:
            print("No reply (timeout)")

    sock.close()


if __name__ == "__main__":
    main()
