# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
### BEGIN LICENSE
# Copyright (c) 2025
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranties of
# MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

"""
General URL Downloader for Variety

Downloads images from direct URLs or scrapes image galleries.
Supports:
- Direct image URLs (jpg, png, webp, etc.)
- HTML pages with images
- Multiple images from a single page
"""

import logging
import random
import re

from variety.plugins.downloaders.DefaultDownloader import DefaultDownloader
from variety.Util import Util

logger = logging.getLogger("variety")


class GeneralURLDownloader(DefaultDownloader):
    """
    Downloads images from any URL - either direct image links or HTML pages.
    """

    def __init__(self, source, url):
        """
        Initialize downloader with a URL.
        
        Args:
            source: The ImageSource instance
            url: URL to download from (direct image or HTML page)
        """
        DefaultDownloader.__init__(self, source=source, config=url)

    def _is_direct_image_url(self, url):
        """Check if URL points directly to an image file"""
        return url.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tiff'))

    def _extract_images_from_html(self, url):
        """
        Scrape HTML page to find image URLs.
        Returns list of image URLs found on the page.
        """
        try:
            soup = Util.html_soup(url)
            image_urls = []

            # Find all img tags
            for img in soup.find_all('img'):
                src = img.get('src') or img.get('data-src')
                if src:
                    # Make absolute URL
                    if src.startswith('//'):
                        src = 'https:' + src
                    elif src.startswith('/'):
                        from urllib.parse import urlparse
                        parsed = urlparse(url)
                        src = f"{parsed.scheme}://{parsed.netloc}{src}"
                    elif not src.startswith('http'):
                        continue
                    
                    # Filter out small images (likely icons/thumbnails)
                    if any(x in src.lower() for x in ['icon', 'logo', 'avatar', 'thumb']):
                        continue
                    
                    if self._is_direct_image_url(src):
                        image_urls.append(src)

            # Also check for links to images
            for link in soup.find_all('a'):
                href = link.get('href')
                if href and self._is_direct_image_url(href):
                    if href.startswith('//'):
                        href = 'https:' + href
                    elif href.startswith('/'):
                        from urllib.parse import urlparse
                        parsed = urlparse(url)
                        href = f"{parsed.scheme}://{parsed.netloc}{href}"
                    
                    if href.startswith('http'):
                        image_urls.append(href)

            return list(set(image_urls))  # Remove duplicates

        except Exception:
            logger.exception(lambda: f"Could not extract images from {url}")
            return []

    def fill_queue(self):
        """
        Fetch images from the URL.
        Returns list of (origin_url, image_url, extra_metadata) tuples.
        """
        logger.info(lambda: f"General URL: {self.config}")

        queue = []
        
        try:
            # Check if it's a direct image URL
            if self._is_direct_image_url(self.config):
                logger.info(lambda: "Direct image URL detected")
                
                extra_metadata = {
                    "sourceType": "url",
                    "sfwRating": 100,
                    "headline": "Direct image download",
                }
                
                queue.append((self.config, self.config, extra_metadata))
            
            else:
                # Try to extract images from HTML page
                logger.info(lambda: "Attempting to extract images from HTML page")
                
                image_urls = self._extract_images_from_html(self.config)
                logger.info(lambda: f"Found {len(image_urls)} images on page")

                for image_url in image_urls:
                    try:
                        # Skip if already downloaded
                        try:
                            if self.is_in_downloaded(image_url):
                                continue
                        except Exception:
                            pass

                        extra_metadata = {
                            "sourceType": "url",
                            "sfwRating": 100,
                            "headline": "Image from custom URL",
                            "description": f"Downloaded from {self.config}",
                        }

                        queue.append((self.config, image_url, extra_metadata))

                    except Exception:
                        logger.exception(lambda: "Could not process an image URL")

        except Exception:
            logger.exception(lambda: "Failed to fetch from URL")

        random.shuffle(queue)
        logger.info(lambda: f"Queue populated with {len(queue)} images")
        return queue
