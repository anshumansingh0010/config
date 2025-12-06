import sys
import os
from PIL import Image, ImageFilter

WIDGET_SIZE = 300
SCREEN_W = 1920
SCREEN_H = 1080
PADDING = 50

def clamp_inside(x, y):
    max_x = SCREEN_W - WIDGET_SIZE - PADDING
    max_y = SCREEN_H - WIDGET_SIZE - PADDING
    x = max(PADDING, min(x, max_x))
    y = max(PADDING, min(y, max_y))
    return x, y

def find_best_spot(wallpaper_path):
    try:
        if not os.path.exists(wallpaper_path):
            return clamp_inside(PADDING, PADDING)

        img = Image.open(wallpaper_path)
        img = img.resize((SCREEN_W, SCREEN_H))
        gray = img.convert("L")
        edges = gray.filter(ImageFilter.FIND_EDGES)

        scale = 0.1
        small_w = int(SCREEN_W * scale)
        small_h = int(SCREEN_H * scale)

        small_edges = edges.resize((small_w, small_h), resample=Image.BILINEAR)

        pixels = list(small_edges.getdata())
        width = small_w

        w_scaled = int(WIDGET_SIZE * scale)
        h_scaled = int(WIDGET_SIZE * scale)

        # Compute VALID SEARCH RANGE (scaled)
        min_x_s = int(PADDING * scale)
        max_x_s = int((SCREEN_W - WIDGET_SIZE - PADDING) * scale)

        min_y_s = int(PADDING * scale)
        max_y_s = int((SCREEN_H - WIDGET_SIZE - PADDING) * scale)

        min_energy = float('inf')
        best_x = min_x_s
        best_y = min_y_s

        step = 5

        for y in range(min_y_s, max_y_s - h_scaled, step):
            for x in range(min_x_s, max_x_s - w_scaled, step):
                energy = 0
                for by in range(0, h_scaled, 2):
                    row_off = (y + by) * width
                    for bx in range(0, w_scaled, 2):
                        energy += pixels[row_off + (x + bx)]

                if energy < min_energy:
                    min_energy = energy
                    best_x = x
                    best_y = y

        # upscale result
        final_x = int(best_x / scale)
        final_y = int(best_y / scale)

        return clamp_inside(final_x, final_y)

    except Exception:
        return clamp_inside(PADDING, PADDING)


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        try:
            SCREEN_W = int(float(sys.argv[1]))
            SCREEN_H = int(float(sys.argv[2]))
        except:
            pass

    path_file = "/home/jay/.local/state/caelestia/wallpaper/path.txt"

    if os.path.exists(path_file):
        wp_path = open(path_file).read().strip()
        x, y = find_best_spot(wp_path)
        print(x, y)
    else:
        print(PADDING, PADDING)
