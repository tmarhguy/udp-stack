#!/usr/bin/env python3
"""Wire-level sanity check for board echo."""

from __future__ import annotations

import subprocess
import sys

from send_udp import main as send_main


if __name__ == "__main__":
    print("Running UDP echo bench...")
    sys.argv = ["send_udp.py", "--host", "255.255.255.255", "--payload", "bench"]
    send_main()
