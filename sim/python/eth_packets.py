"""Ethernet / IP / UDP frame builders for cocotb tests."""

from __future__ import annotations

import struct
from typing import Iterable


def _mac_bytes(mac: str) -> bytes:
    return bytes(int(x, 16) for x in mac.split(":"))


def ipv4_checksum(header: bytes) -> int:
    if len(header) % 2:
        header += b"\x00"
    s = sum(struct.unpack("!%dH" % (len(header) // 2), header))
    while s >> 16:
        s = (s & 0xFFFF) + (s >> 16)
    return (~s) & 0xFFFF


def build_ipv4_udp_packet(
    src_mac: str,
    dst_mac: str,
    src_ip: str,
    dst_ip: str,
    src_port: int,
    dst_port: int,
    payload: bytes,
) -> bytes:
    eth = _mac_bytes(dst_mac) + _mac_bytes(src_mac) + b"\x08\x00"

    ver_ihl = 0x45
    total_len = 20 + 8 + len(payload)
    ip_hdr = struct.pack(
        "!BBHHHBBH4s4s",
        ver_ihl,
        0,
        total_len,
        0x1234,
        0,
        64,
        17,
        0,
        bytes(map(int, src_ip.split("."))),
        bytes(map(int, dst_ip.split("."))),
    )
    csum = ipv4_checksum(ip_hdr)
    ip_hdr = ip_hdr[:10] + struct.pack("!H", csum) + ip_hdr[12:]

    udp_len = 8 + len(payload)
    udp_hdr = struct.pack("!HHHH", src_port, dst_port, udp_len, 0)
    return eth + ip_hdr + udp_hdr + payload


def iter_frame_bytes(frame: bytes) -> Iterable[tuple[int, bool]]:
    for i, b in enumerate(frame):
        yield b, i == len(frame) - 1
