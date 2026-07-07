"""Generate ninja app icon from emoji"""
from PIL import Image, ImageDraw, ImageFont
import os

size = 256
img = Image.new('RGBA', (size, size), (229, 57, 53, 255))
draw = ImageDraw.Draw(img)

# Try to use Windows emoji font
try:
    font = ImageFont.truetype("seguiemj.ttf", 180)
except Exception:
    font = ImageFont.load_default()

draw.text((size // 2, size // 2), "🥷", fill="white", font=font, anchor="mm")

# Save as multi-size .ico
out = os.path.join(os.path.dirname(__file__), "app_icon.ico")
img.save(out, format="ICO", sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)])
print(f"Done: {out}")
