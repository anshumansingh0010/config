import sys
import os
from PIL import Image, ImageStat

WIDGET_SIZE = 300
SCREEN_W = 1920
SCREEN_H = 1080 # Assumption, or could pass as args
PADDING = 50    # Keep away from edges

def find_best_spot(wallpaper_path):
    try:
        if not os.path.exists(wallpaper_path):
            return PADDING, PADDING

        img = Image.open(wallpaper_path.strip())
        img = img.resize((SCREEN_W, SCREEN_H))
        gray = img.convert('L')
        
        # 1. Edge Detection to find "busy" areas vs "empty" areas
        # This highlights boundaries of objects. We want to avoid them.
        from PIL import ImageFilter
        edges = gray.filter(ImageFilter.FIND_EDGES)
        
        # 2. Downscale for performance (analyze at 1/10th resolution)
        scale = 0.1
        small_w = int(SCREEN_W * scale)
        small_h = int(SCREEN_H * scale)
        small_edges = edges.resize((small_w, small_h), resample=Image.BILINEAR)
        
        # Scaled widget size
        w_scaled = int(WIDGET_SIZE * scale)
        h_scaled = int(WIDGET_SIZE * scale)
        
        # 3. Sliding Window Search
        # We look for the rectangle with the LOWEST sum of edge pixels (least detail)
        min_energy = float('inf')
        best_x = 0
        best_y = 0
        
        pixels = list(small_edges.getdata())
        width = small_w
        
        # Helper to calculate sum in a region (naive approach is fine for this small size)
        # Optimized: Integral image would be faster but for ~200x100 image, 
        # a step-based sliding window is fast enough.
        
        step = 5 # step size in small coords (effective 50px step)
        
        for y in range(0, small_h - h_scaled, step):
            for x in range(0, small_w - w_scaled, step):
                # Calculate energy in this rect
                current_energy = 0
                # Sampling pixels in the box
                for by in range(0, h_scaled, 2): # sample every 2nd line for speed
                    row_offset = (y + by) * width
                    for bx in range(0, w_scaled, 2):
                        current_energy += pixels[row_offset + (x + bx)]
                
                if current_energy < min_energy:
                    min_energy = current_energy
                    best_x = x
                    best_y = y

        # 4. Map back to screen coords
        final_x = int(best_x / scale)
        final_y = int(best_y / scale)
        
        # Clamp with Padding
        final_x = max(PADDING, min(final_x, SCREEN_W - WIDGET_SIZE - PADDING))
        final_y = max(PADDING, min(final_y, SCREEN_H - WIDGET_SIZE - PADDING))

        return final_x, final_y

    except Exception as e:
        # print(f"Error: {e}", file=sys.stderr)
        return PADDING, PADDING

    except Exception as e:
        return 100, 100 

if __name__ == "__main__":
    # Check for resolution args
    if len(sys.argv) >= 3:
        try:
            SCREEN_W = int(float(sys.argv[1])) # Handle float strings just in case
            SCREEN_H = int(float(sys.argv[2]))
        except:
            pass

    path_file = "/home/jay/.local/state/caelestia/wallpaper/path.txt"
    if os.path.exists(path_file):
        with open(path_file, 'r') as f:
            wp_path = f.read().strip()
            x, y = find_best_spot(wp_path)
            print(f"{x} {y}")
    else:
        # Fallback
        print("100 100")
