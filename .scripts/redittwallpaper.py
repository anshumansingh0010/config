from bs4 import BeautifulSoup
import requests
import shutil
import sys
import logging
from datetime import datetime
import re
import ctypes
import os

logging.basicConfig(level=logging.INFO)
logging.info("Fetching HTML page ...")

url_base = 'https://www.reddit.com'
url = 'https://www.reddit.com/r/wallpaper/top/?t=day'

try:
    html_page = requests.get(url)
    html_page.raise_for_status()
    logging.info("r/Wallpaper/top/day page fetched successfully!")
except requests.exceptions.RequestException as e:
    print(f"Error fetching HTML page: {e}")
    sys.exit(1)

soup = BeautifulSoup(html_page.content, 'html.parser')
posts = soup.find_all('a', class_='absolute inset-0')

download_folder = r'~/Pictures/Wallpapers/ '  
download_folder = os.path.expanduser(download_folder)



for post in posts:
    source = post.attrs.get('href', '')  # Ensure source is a string
    if not isinstance(source, str):
        print("Invalid source attribute, skipping post.")
        continue
    full_url = url_base + source

    try:
        html_page2 = requests.get(full_url)
        html_page2.raise_for_status()
        logging.info("Post to image fetched successfully!")
    except requests.exceptions.RequestException as t:
        print(f"Error fetching HTML page: {t}")
        continue

    soup2 = BeautifulSoup(html_page2.content, 'html.parser')
    shreddit_title_tag = soup2.find('shreddit-title')

    if shreddit_title_tag:
        title = shreddit_title_tag.get('title')
        if not isinstance(title, str):
            print("Invalid title attribute, skipping post.")
            continue
        title_without_brackets = re.sub(r'\[.*?\]', '', title)
        split_title = title_without_brackets.split(':')

        if len(split_title) > 1:
            desired_part = split_title[0].strip()
        else:
            print("Can't find colon")
            desired_part = f"generic_title_{datetime.now().strftime('%Y-%m-%d')}"
    else:
        print("Can't find <shreddit-title>-Tag.")
        desired_part = f"generic_title_{datetime.now().strftime('%Y-%m-%d')}"

    desired_part = desired_part.replace(',', '_').replace("'", '')
    desired_part = re.sub(r'[<>:"/\\|?*]', '_', desired_part)

    download_folder = r'X:\Photos\Wallpapers\Reddit'
    current_date = datetime.now().strftime('%Y-%m-%d')

    try:
        html_post_page = requests.get(full_url)
        html_post_page.raise_for_status()
        post_soup = BeautifulSoup(html_post_page.content, 'html.parser')
        element2 = post_soup.find('div', class_="max-h-[100vw] h-full w-full object-contain overflow-hidden relative bg-black")

        if element2:
            a_element = element2.find('a')
            if a_element and 'href' in a_element.attrs:
                full_img = a_element.attrs['href']
                if not isinstance(full_img, str):
                    print("Invalid image URL, skipping post.")
                    continue
            else:
                print("Post with 2 or more Images, moving to next post.")
                continue
        else:
            print("Post with 2 or more Images, moving to next post.")
            continue

        file_name = os.path.join(download_folder, f"{desired_part}_{current_date}.png")

        try:
            r = requests.get(full_img, stream=True)
            r.raise_for_status()

            with open(file_name, 'wb') as f:
                r.raw.decode_content = True
                shutil.copyfileobj(r.raw, f)
                print(f"Downloading wallpaper: {desired_part} ({current_date})")

            SPI_SETDESKWALLPAPER = 20
            WALLPAPER_PATH = file_name

            if os.name == 'nt':  # Check if the OS is Windows
                try:
                    ctypes.windll.user32.SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, WALLPAPER_PATH, 3)
                    print("Wallpaper change successful!")
                    break
                except Exception as e:
                    print(f"Wallpaper change failed: {e}")
                    break
            else:
                print("Wallpaper change is only supported on Windows.")
        except requests.exceptions.RequestException as e:
            print(f"Error downloading image: {e}")
            continue
    except requests.exceptions.RequestException as p:
        print(f"Error fetching post page: {p}")
        continue

print("Script completed.")
