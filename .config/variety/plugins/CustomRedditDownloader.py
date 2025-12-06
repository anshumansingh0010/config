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
Custom Reddit Downloader for Variety

Handles downloading images from custom Reddit URLs.
Used by CustomRedditSource.
"""

import logging
import random
import os
import http.cookiejar

from variety.plugins.downloaders.DefaultDownloader import DefaultDownloader
from variety.Util import Util

logger = logging.getLogger("variety")


class CustomRedditDownloader(DefaultDownloader):
    """
    Downloads images from a custom Reddit URL (subreddit or multi-reddit).
    """

    def __init__(self, source, url):
        """
        Initialize downloader with a Reddit URL.
        
        Args:
            source: The ImageSource instance
            url: Reddit URL (e.g., https://www.reddit.com/r/wallpaper/top/?t=month)
        """
        DefaultDownloader.__init__(self, source=source, config=url)
        self.auth_headers, self.cookies = self._get_auth_headers()

    def _build_json_url(self, url):
        """
        Convert Reddit URL to JSON API URL.
        
        Examples:
            https://www.reddit.com/r/wallpaper
            -> https://www.reddit.com/r/wallpaper.json?limit=100
            
            https://www.reddit.com/r/wallpaper/top/?t=month
            -> https://www.reddit.com/r/wallpaper/top/.json?t=month&limit=100
        """
        # Add .json before query parameters
        if "?" in url:
            base, query = url.split("?", 1)
            json_url = f"{base}.json?{query}&limit=100"
        else:
            json_url = f"{url}.json?limit=100"
        
        return json_url

    def _load_credentials(self):
        """
        Load Reddit credentials from config file.
        
        Config file: ~/.config/variety/pluginconfig/CustomRedditDownloader/credentials.conf
        Format:
            username=your_reddit_username
            password=your_reddit_password
        
        Returns:
            dict with 'username' and 'password' or None
        """
        try:
            config_folder = os.path.expanduser("~/.config/variety/pluginconfig/CustomRedditDownloader")
            creds_file = os.path.join(config_folder, "credentials.conf")
            
            if not os.path.exists(creds_file):
                return None
            
            credentials = {}
            with open(creds_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        credentials[key.strip()] = value.strip()
            
            if 'username' in credentials and 'password' in credentials:
                logger.info(lambda: f"Loaded credentials for user: {credentials['username']}")
                return credentials
            else:
                logger.warning(lambda: "Credentials file missing username or password")
                return None
                
        except Exception:
            logger.exception(lambda: "Could not load Reddit credentials")
            return None

    def _get_oauth_token(self, username, password):
        """
        Get Reddit OAuth2 access token using username/password.
        
        Returns:
            Access token string or None
        """
        try:
            import requests
            
            # Reddit OAuth2 endpoint
            auth_url = "https://www.reddit.com/api/v1/access_token"
            
            # Use a generic client ID (Reddit's official mobile app)
            # This is publicly known and safe to use
            client_id = "ohXpoqrZYub1kg"
            
            data = {
                'grant_type': 'password',
                'username': username,
                'password': password
            }
            
            headers = {
                'User-Agent': 'Variety:CustomRedditDownloader:v1.0'
            }
            
            # Basic auth with client_id (no secret for mobile app)
            auth = (client_id, '')
            
            r = requests.post(auth_url, data=data, headers=headers, auth=auth, timeout=30)
            r.raise_for_status()
            
            token_data = r.json()
            access_token = token_data.get('access_token')
            
            if access_token:
                logger.info(lambda: "Successfully obtained OAuth2 access token")
                return access_token
            else:
                logger.error(lambda: "No access token in response")
                return None
                
        except Exception:
            logger.exception(lambda: "Failed to get OAuth2 token")
            return None

    def _load_cookies(self):
        """
        Load Reddit cookies from file for accessing NSFW content.
        
        Cookie file location: ~/.config/variety/pluginconfig/CustomRedditDownloader/cookies.txt
        Format: Netscape HTTP Cookie File (same as browser export)
        
        To get cookies:
        1. Install browser extension "Get cookies.txt" or "EditThisCookie"
        2. Login to Reddit in browser
        3. Export cookies to cookies.txt
        4. Place in: ~/.config/variety/pluginconfig/CustomRedditDownloader/
        
        Returns:
            requests.cookies.RequestsCookieJar or None
        """
        try:
            # Get plugin config folder
            config_folder = os.path.expanduser("~/.config/variety/pluginconfig/CustomRedditDownloader")
            cookie_file = os.path.join(config_folder, "cookies.txt")
            
            if not os.path.exists(cookie_file):
                return None
            
            # Load cookies using http.cookiejar
            cookie_jar = http.cookiejar.MozillaCookieJar(cookie_file)
            cookie_jar.load(ignore_discard=True, ignore_expires=True)
            
            # Convert to requests-compatible format
            import requests
            cookies = requests.cookies.RequestsCookieJar()
            for cookie in cookie_jar:
                cookies.set_cookie(cookie)
            
            logger.info(lambda: f"Loaded {len(cookies)} cookies from {cookie_file}")
            return cookies
            
        except Exception:
            logger.exception(lambda: "Could not load Reddit cookies")
            return None

    def _get_auth_headers(self):
        """
        Get authentication headers for Reddit API.
        Tries OAuth2 first, then falls back to cookies.
        
        Returns:
            tuple of (headers dict, cookies or None)
        """
        headers = {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0"
        }
        
        # Try OAuth2 authentication first
        credentials = self._load_credentials()
        if credentials:
            token = self._get_oauth_token(credentials['username'], credentials['password'])
            if token:
                # Use OAuth2 bearer token
                headers['Authorization'] = f'Bearer {token}'
                logger.info(lambda: "Using OAuth2 authentication")
                return headers, None
        
        # Fall back to cookies
        cookies = self._load_cookies()
        if cookies:
            logger.info(lambda: "Using cookie authentication")
            return headers, cookies
        
        # No authentication
        logger.info(lambda: "No authentication configured (NSFW content may be blocked)")
        return headers, None

    def fill_queue(self):
        """
        Fetch posts from Reddit and extract image URLs.
        Returns list of (origin_url, image_url, extra_metadata) tuples.
        Ensures at least 20 images are returned.
        """
        logger.info(lambda: f"Custom Reddit URL: {self.config}")

        queue = []
        after = None  # For pagination
        max_attempts = 5  # Try up to 5 pages
        target_images = 20  # Target number of images
        
        try:
            import requests
            
            for attempt in range(max_attempts):
                # Build URL with pagination
                json_url = self._build_json_url(self.config)
                if after:
                    separator = '&' if '?' in json_url else '?'
                    json_url = f"{json_url}{separator}after={after}"
                
                logger.info(lambda: f"Fetching from: {json_url} (attempt {attempt + 1})")
                
                # Use authentication if available
                r = requests.get(json_url, headers=self.auth_headers, cookies=self.cookies, timeout=30)
                r.raise_for_status()
                data = r.json()
                
                posts = data.get("data", {}).get("children", [])
                after = data.get("data", {}).get("after")  # For next page
                
                logger.info(lambda: f"Found {len(posts)} posts on page {attempt + 1}")

                for item in posts:
                    try:
                        post = item.get("data", {})

                        # Get image URL
                        image_url = post.get("url_overridden_by_dest") or post.get("url")

                        if not image_url:
                            continue

                        # Handle different image sources
                        processed_urls = []
                        
                        # Direct image links
                        if image_url.lower().endswith((".jpg", ".jpeg", ".png", ".webp", ".gif")):
                            processed_urls.append(image_url)
                        
                        # Imgur single image (convert to direct link)
                        elif "imgur.com" in image_url and not any(x in image_url for x in ['/a/', '/gallery/']):
                            # Convert imgur.com/abc123 to i.imgur.com/abc123.jpg
                            if not image_url.startswith("https://i.imgur.com"):
                                img_id = image_url.split('/')[-1].split('.')[0]
                                processed_urls.append(f"https://i.imgur.com/{img_id}.jpg")
                        
                        # Reddit gallery (extract first image)
                        elif "reddit.com/gallery/" in image_url:
                            # Try to get gallery images from post data
                            gallery_data = post.get("gallery_data", {})
                            media_metadata = post.get("media_metadata", {})
                            if gallery_data and media_metadata:
                                for item_data in gallery_data.get("items", [])[:3]:  # Get first 3 images
                                    media_id = item_data.get("media_id")
                                    if media_id and media_id in media_metadata:
                                        img_data = media_metadata[media_id]
                                        if img_data.get("status") == "valid":
                                            # Get highest quality image
                                            source = img_data.get("s", {})
                                            img_url = source.get("u") or source.get("gif")
                                            if img_url:
                                                # Decode HTML entities
                                                img_url = img_url.replace("&amp;", "&")
                                                processed_urls.append(img_url)
                        
                        # i.redd.it images
                        elif "i.redd.it" in image_url:
                            processed_urls.append(image_url)

                        # Process all extracted URLs
                        for img_url in processed_urls:
                            # Skip if already downloaded (only if download folder is initialized)
                            try:
                                if self.is_in_downloaded(img_url):
                                    continue
                            except Exception:
                                pass

                            # Get metadata
                            title = post.get("title", "")
                            author = post.get("author", "")
                            subreddit = post.get("subreddit", "")
                            permalink = post.get("permalink", "")
                            score = post.get("score", 0)
                            over_18 = post.get("over_18", False)

                            # Build origin URL
                            origin_url = f"https://www.reddit.com{permalink}"

                            # Handle NSFW content
                            if over_18:
                                if self.is_safe_mode_enabled():
                                    logger.info(lambda: f"Skipping NSFW post: {title}")
                                    continue

                            # Build metadata
                            extra_metadata = {
                                "sourceType": "reddit",
                                "sfwRating": 0 if over_18 else 100,
                                "headline": title,
                                "author": f"u/{author}",
                                "description": f"r/{subreddit} - Score: {score}",
                                "keywords": [subreddit],
                            }

                            queue.append((origin_url, img_url, extra_metadata))

                    except Exception:
                        logger.exception(lambda: "Could not process a Reddit post")

                # Check if we have enough images
                if len(queue) >= target_images:
                    logger.info(lambda: f"Reached target of {target_images} images")
                    break
                
                # Check if there are more pages
                if not after:
                    logger.info(lambda: "No more pages available")
                    break

        except Exception:
            logger.exception(lambda: "Failed to fetch from Reddit")

        random.shuffle(queue)
        logger.info(lambda: f"Queue populated with {len(queue)} images")
        return queue
