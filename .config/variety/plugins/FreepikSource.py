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
Freepik Source Plugin for Variety  (web-scraping edition — no API key needed)

Adds Freepik as a wallpaper source in Variety's UI.
Users enter a search term and Variety scrapes matching free photos from
Freepik's public search pages — exactly what a normal browser would do.

Installation:
    Place both FreepikSource.py and FreepikDownloader.py in:
        ~/.config/variety/plugins/
"""

import logging
import sys
import os

from variety.plugins.downloaders.ConfigurableImageSource import ConfigurableImageSource
from variety.Util import Util, _

# Ensure the user plugins directory is on sys.path so FreepikDownloader can
# be imported regardless of how Jumble sets up the module search path.
_plugins_dir = os.path.dirname(os.path.abspath(__file__))
if _plugins_dir not in sys.path:
    sys.path.insert(0, _plugins_dir)

from FreepikDownloader import FreepikDownloader

logger = logging.getLogger("variety")


class FreepikSource(ConfigurableImageSource):
    """
    Configurable Variety source that fetches wallpapers from Freepik.

    Users enter a search term in Variety's "Add Source" dialog.
    The downloader searches Freepik for landscape-oriented photos and
    presents them as desktop wallpapers.
    """

    # ------------------------------------------------------------------
    # Plugin metadata
    # ------------------------------------------------------------------

    @classmethod
    def get_info(cls):
        return {
            "name": "FreepikSource",
            "description": _("Download high-quality photos from Freepik"),
            "author": "Variety Community",
            "version": "1.0",
        }

    # ------------------------------------------------------------------
    # Source identity
    # ------------------------------------------------------------------

    def get_source_type(self):
        """Unique type key — stored in variety.conf."""
        return "freepik"

    def get_source_name(self):
        """Label shown in the sources list."""
        return "Freepik"

    # ------------------------------------------------------------------
    # UI text
    # ------------------------------------------------------------------

    def get_ui_instruction(self):
        return _(
            "Enter a search term to find wallpaper-quality free photos on Freepik.\\n\\n"
            "<b>Examples:</b>\\n"
            "• <tt>nature landscape</tt>\\n"
            "• <tt>abstract background</tt>\\n"
            "• <tt>mountains sunset</tt>\\n"
            "• <tt>ocean waves</tt>\\n"
            "• <tt>random</tt> — picks from a built-in variety of topics\\n\\n"
            "<b>No account or API key required.</b> Freepik's free photos are fetched\\n"
            "just like a normal browser would — for personal wallpaper use."
        )

    def get_ui_short_instruction(self):
        return _("Search term (e.g. 'nature landscape'):")

    def get_ui_short_description(self):
        return _("Fetch photos from Freepik")

    # ------------------------------------------------------------------
    # Validation
    # ------------------------------------------------------------------

    def validate(self, query):
        """
        Validate the user's search term.

        Returns:
            (normalized_query, error_message)   — error_message is None on success.
        """
        logger.info(lambda: f"FreepikSource.validate({query!r})")

        query = (query or "").strip()
        if not query:
            return False, _("Please enter a search term (e.g. 'nature landscape').")

        # Accept 'random' as a valid special keyword
        return query, None

    # ------------------------------------------------------------------
    # Downloader factory
    # ------------------------------------------------------------------

    def create_downloader(self, config):
        """
        Create a FreepikDownloader for the given (validated) search term.

        Args:
            config: The normalised search term returned by validate().

        Returns:
            FreepikDownloader instance.
        """
        return FreepikDownloader(self, config)
