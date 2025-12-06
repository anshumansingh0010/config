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
General URL Source Plugin for Variety

Allows users to add any URL as an image source through Variety's UI.
Place both this file and GeneralURLDownloader.py in: ~/.config/variety/plugins/

Examples of what you can add:
- Direct image: https://example.com/image.jpg
- Image gallery: https://example.com/gallery.html
- Any webpage with images
"""

import logging

from variety.plugins.downloaders.ConfigurableImageSource import ConfigurableImageSource
from variety.Util import Util, _

# Import the downloader from the same directory
try:
    from GeneralURLDownloader import GeneralURLDownloader
except ImportError:
    from variety.plugins.GeneralURLDownloader import GeneralURLDownloader

logger = logging.getLogger("variety")


class GeneralURLSource(ConfigurableImageSource):
    """
    Configurable source for fetching images from any URL.
    Users can specify direct image URLs or HTML pages containing images.
    """

    @classmethod
    def get_info(cls):
        """Plugin metadata"""
        return {
            "name": "GeneralURLSource",
            "description": _("Download images from any URL"),
            "author": "Variety Community",
            "version": "1.0",
        }

    def get_source_type(self):
        """Unique identifier for this source"""
        return "url"

    def get_source_name(self):
        """Display name shown in Variety UI"""
        return "URL"

    def get_ui_instruction(self):
        """Detailed instructions shown in the add source dialog"""
        return _(
            "Enter a direct image URL or a webpage containing images.\\n\\n"
            "<b>Examples:</b>\\n"
            "• Direct image: <tt>https://example.com/wallpaper.jpg</tt>\\n"
            "• Image gallery: <tt>https://example.com/gallery.html</tt>\\n"
            "• Any webpage: <tt>https://example.com/images/</tt>\\n\\n"
            "<b>Supported formats:</b> jpg, jpeg, png, gif, webp, bmp, tiff\\n\\n"
            "<b>Note:</b> For HTML pages, Variety will extract all images found on the page."
        )

    def get_ui_short_instruction(self):
        """Short label shown in the input field"""
        return _("Image URL or webpage:")

    def get_ui_short_description(self):
        """Brief description shown in source list"""
        return _("Download from any URL")

    def validate(self, query):
        """
        Validate and normalize the user's input.
        
        Args:
            query: User input (URL)
            
        Returns:
            Tuple of (normalized_url, error_message)
            error_message is None if validation succeeds
        """
        logger.info(lambda: f"Validating URL: {query}")
        
        # Normalize the URL
        query = query.strip()
        
        # Add https:// if missing
        if not query.startswith("http://") and not query.startswith("https://"):
            query = "https://" + query
        
        # Basic URL validation
        if not ("://" in query and "." in query):
            return False, _("This does not seem to be a valid URL")
        
        # Try to fetch and validate
        try:
            dl = GeneralURLDownloader(self, query)
            queue = dl.fill_queue()
            
            if len(queue) > 0:
                return query, None  # Success
            else:
                return query, _("No images found at this URL. Try a direct image link or a page with images.")
                
        except Exception as e:
            logger.exception(lambda: f"Error validating URL: {e}")
            return query, _("Could not access this URL. Check the address and try again.")

    def create_downloader(self, config):
        """
        Create a downloader instance for the validated config.
        
        Args:
            config: The validated URL from validate()
            
        Returns:
            GeneralURLDownloader instance
        """
        return GeneralURLDownloader(self, config)
