#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
from variety import VarietyPlugin

metadata = {
    "name": "Reddit Wallpaper Fetcher",
    "description": "Fetch top wallpapers from r/wallpaper",
    "author": "You",
    "version": "1.0",
}

HEADERS = {
    "User-Agent": "Mozilla/5.0",
}

class Plugin(VarietyPlugin):
    def get_images(self):
        url = "https://www.reddit.com/r/wallpaper/top/.json?t=day&limit=20"
        r = requests.get(url, headers=HEADERS)
        data = r.json()

        images = []
        for post in data["data"]["children"]:
            src = post["data"].get("url_overridden_by_dest") or ""
            if src.endswith((".jpg", ".jpeg", ".png")):
                images.append(src)

        return images
