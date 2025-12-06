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
Custom Reddit Source Plugin for Variety

Allows users to add custom subreddits or multi-reddits through Variety's UI.
Place both this file and CustomRedditDownloader.py in: ~/.config/variety/plugins/

Examples of what you can add:
- Single subreddit: wallpaper
- Full URL: https://www.reddit.com/r/wallpaper
- Top posts: https://www.reddit.com/r/wallpaper/top/?t=month
- Multi-reddit: wallpaper+wallpapers+EarthPorn
- Multi URL: https://www.reddit.com/r/wallpaper+wallpapers+EarthPorn/top/?t=week
"""

import logging

from variety.plugins.downloaders.ConfigurableImageSource import ConfigurableImageSource
from variety.Util import Util, _

# Import the downloader from the same directory
try:
    from CustomRedditDownloader import CustomRedditDownloader
except ImportError:
    # Fallback for different import contexts
    from variety.plugins.CustomRedditDownloader import CustomRedditDownloader

logger = logging.getLogger("variety")


class CustomRedditSource(ConfigurableImageSource):
    """
    Configurable source for fetching images from custom Reddit URLs.
    Users can specify subreddits, multi-reddits, sort order, and time period.
    """

    @classmethod
    def get_info(cls):
        """Plugin metadata"""
        return {
            "name": "CustomRedditSource",
            "description": _("Add custom subreddits or multi-reddits"),
            "author": "Variety Community",
            "version": "1.0",
        }

    def get_source_type(self):
        """Unique identifier for this source"""
        return "reddit"

    def get_source_name(self):
        """Display name shown in Variety UI"""
        return "Reddit"

    def get_ui_instruction(self):
        """Detailed instructions shown in the add source dialog"""
        return _(
            "Enter a subreddit name, multi-reddit, or full Reddit URL.\\n\\n"
            "\u003cb\u003eExamples:\u003c/b\u003e\\n"
            "• Simple: \u003ctt\u003ewallpaper\u003c/tt\u003e\\n"
            "• Multi: \u003ctt\u003ewallpaper+wallpapers+EarthPorn\u003c/tt\u003e\\n"
            "• Top of month: \u003ctt\u003ewallpaper/top/?t=month\u003c/tt\u003e\\n"
            "• Full URL: \u003ctt\u003ehttps://www.reddit.com/r/wallpaper/top/?t=week\u003c/tt\u003e\\n\\n"
            "\u003cb\u003eTime periods:\u003c/b\u003e hour, day, week, month, year, all\\n"
            "\u003cb\u003eSort options:\u003c/b\u003e hot, new, top, rising"
        )

    def get_ui_short_instruction(self):
        """Short label shown in the input field"""
        return _("Subreddit or Reddit URL:")

    def get_ui_short_description(self):
        """Brief description shown in source list"""
        return _("Fetch images from custom subreddits")

    def validate(self, query):
        """
        Validate and normalize the user's input.
        
        Args:
            query: User input (subreddit name or URL)
            
        Returns:
            Tuple of (normalized_url, error_message)
            error_message is None if validation succeeds
        """
        logger.info(lambda: f"Validating Reddit query: {query}")
        
        # Normalize the query to a full URL
        query = query.strip()
        
        # If it's just a subreddit name or multi-reddit
        if not "/" in query:
            query = f"https://www.reddit.com/r/{query}"
        
        # Add https:// if missing
        if not query.startswith("http://") and not query.startswith("https://"):
            query = "https://" + query
        
        # Validate it's a Reddit URL
        if "reddit.com" not in query:
            return False, _("This does not seem to be a valid Reddit URL")
        
        # Try to fetch and validate
        try:
            dl = CustomRedditDownloader(self, query)
            queue = dl.fill_queue()
            
            if len(queue) > 0:
                return query, None  # Success
            else:
                return query, _("No images found. Try a different subreddit or time period.")
                
        except Exception as e:
            logger.exception(lambda: f"Error validating Reddit URL: {e}")
            return query, _("Could not fetch from this URL. Check the subreddit name.")

    def create_downloader(self, config):
        """
        Create a downloader instance for the validated config.
        
        Args:
            config: The validated URL from validate()
            
        Returns:
            CustomRedditDownloader instance
        """
        return CustomRedditDownloader(self, config)
