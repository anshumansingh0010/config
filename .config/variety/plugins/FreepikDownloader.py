# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
### BEGIN LICENSE
# Copyright (c) 2025
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
### END LICENSE

"""
Freepik Downloader for Variety — Official API edition (no watermarks)

Uses the Freepik API to:
  1. Search for free photos matching the user's query
  2. Obtain signed, watermark-free download URLs via the download endpoint
  3. Stream the image directly into Variety's download folder

Config file: ~/.config/variety/pluginconfig/FreepikDownloader/config.conf
  api_key=FPSXyourkey

Get a FREE key at: https://www.freepik.com/developers/dashboard
"""

import logging
import os
import random

import requests

from variety.plugins.downloaders.DefaultDownloader import DefaultDownloader

logger = logging.getLogger("variety")

FREEPIK_API = "https://api.freepik.com/v1"

DEFAULT_TOPICS = [
    "nature landscape",
    "mountain sunset",
    "ocean waves",
    "abstract background",
    "forest",
    "city skyline night",
    "space galaxy",
    "flowers meadow",
    "desert dunes",
    "northern lights aurora",
    "tropical beach",
    "autumn leaves",
    "waterfall",
    "snowy mountains",
    "rainy city street",
]


class FreepikDownloader(DefaultDownloader):
    """
    Downloads watermark-free photos from Freepik using the official REST API.
    The /download endpoint returns a signed URL that bypasses watermarking.
    """

    def __init__(self, source, query: str):
        DefaultDownloader.__init__(self, source=source, config=query)
        self.api_key = self._load_api_key()

    # ------------------------------------------------------------------
    # Config
    # ------------------------------------------------------------------

    def _load_api_key(self) -> str | None:
        try:
            conf = os.path.expanduser(
                "~/.config/variety/pluginconfig/FreepikDownloader/config.conf"
            )
            if not os.path.exists(conf):
                logger.warning(lambda: f"Freepik: config not found at {conf}")
                return None
            with open(conf) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        if k.strip() == "api_key":
                            key = v.strip().strip('"').strip("'")
                            if key and key != "YOUR_KEY_HERE":
                                logger.info(lambda: "Freepik: API key loaded")
                                return key
            logger.warning(lambda: "Freepik: api_key missing or placeholder in config")
        except Exception:
            logger.exception(lambda: "Freepik: could not read config")
        return None

    # ------------------------------------------------------------------
    # API helpers
    # ------------------------------------------------------------------

    def _headers(self) -> dict:
        return {
            "x-freepik-api-key": self.api_key,
            "Accept-Language": "en-US",
            "Accept": "application/json",
        }

    def _effective_query(self) -> str:
        q = (self.config or "").strip()
        if not q or q.lower() == "random":
            return random.choice(DEFAULT_TOPICS)
        return q

    def _search(self, term: str, page: int = 1, limit: int = 20) -> list[dict]:
        """Search Freepik for landscape photos matching *term*."""
        params = {
            "term": term,
            "limit": limit,
            "page": page,
            "order": "relevance",
            "filters[image_type][photos]": 1,
            "filters[orientation][landscape]": 1,
        }
        try:
            r = requests.get(
                f"{FREEPIK_API}/resources",
                headers=self._headers(),
                params=params,
                timeout=30,
            )
            r.raise_for_status()
            resources = r.json().get("data", [])
            logger.info(lambda: f"Freepik search '{term}' p{page}: {len(resources)} results")
            return resources
        except requests.HTTPError as exc:
            code = exc.response.status_code if exc.response is not None else "?"
            if code == 401:
                logger.error(lambda: "Freepik API 401 – check api_key in config.conf")
            elif code == 402:
                logger.error(lambda: "Freepik API 402 – insufficient credits")
            else:
                logger.exception(lambda: f"Freepik search HTTP {code}")
        except Exception:
            logger.exception(lambda: "Freepik search failed")
        return []

    def _signed_url(self, resource_id: int) -> tuple[str | None, str | None]:
        """
        Call the download endpoint to get a watermark-free signed URL.
        Returns (signed_url, filename) or (None, None).
        """
        try:
            r = requests.get(
                f"{FREEPIK_API}/resources/{resource_id}/download",
                headers=self._headers(),
                params={"size": "original"},
                timeout=30,
            )
            r.raise_for_status()
            payload = r.json()
            # API returns either a flat dict or one wrapped in "data"
            data = payload.get("data") or payload
            url = data.get("signed_url") or data.get("url")
            print("urlsigned ", url)
            fname = data.get("filename", f"freepik_{resource_id}.jpg")
            return url, fname
        except requests.HTTPError as exc:
            code = exc.response.status_code if exc.response is not None else "?"
            if code == 402:
                logger.warning(lambda: f"Freepik resource {resource_id}: needs premium – skipping")
            else:
                logger.exception(lambda: f"Freepik download URL error for {resource_id}")
        except Exception:
            logger.exception(lambda: f"Freepik: no download URL for {resource_id}")
        return None, None

    # ------------------------------------------------------------------
    # fill_queue
    # ------------------------------------------------------------------

    def fill_queue(self) -> list[tuple]:
        if not self.api_key:
            logger.error(lambda: (
                "Freepik: no API key. Add api_key=YOUR_KEY to "
                "~/.config/variety/pluginconfig/FreepikDownloader/config.conf"
            ))
            return []

        term = self._effective_query()
        logger.info(lambda: f"FreepikDownloader.fill_queue() term={term!r}")

        queue: list[tuple] = []

        for page in range(1, 4):
            resources = self._search(term, page=page, limit=20)
            if not resources:
                break

            for res in resources:
                try:
                    rid = res.get("id")
                    if not rid:
                        continue

                    # Only photos (no vectors / PSDs)
                    img_type = res.get("image", {}).get("type", "")
                    if img_type and img_type != "photo":
                        continue

                    # print(res)
                    origin = res.get("url", f"https://www.freepik.com/resource/{rid}")

                    # Skip already downloaded
                    try:
                        if self.is_in_downloaded(origin):
                            continue
                    except Exception:
                        pass

                    # Get watermark-free signed URL
                    signed, _ = self._signed_url(rid)
                    if not signed:
                        continue

                    author = res.get("author", {}).get("name", "Freepik")
                    title = res.get("title", f"Freepik — {term}")
                    stats = res.get("stats", {})

                    extra_metadata = {
                        "sourceType": "freepik",
                        "sfwRating": 100,
                        "headline": title,
                        "author": author,
                        "description": (
                            f"Freepik free photo by {author} | "
                            f"Downloads: {stats.get('downloads', 0)}"
                        ),
                        "keywords": [term, "freepik", "photo"],
                    }
                    print("--------------------------------------------------------------------------\n\n\n")
                    print(origin)
                    print(signed,extra_metadata)
                    queue.append((origin, signed, extra_metadata))
                    print("--------------------------------------------------------------------------\n\n\n")


                except Exception:
                    logger.exception(lambda: "Freepik: error processing resource")

            if len(queue) >= 40:
                break

        random.shuffle(queue)
        logger.info(lambda: f"FreepikDownloader: queue ready — {len(queue)} images")
        return queue
