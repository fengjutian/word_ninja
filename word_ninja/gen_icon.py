"""Generate the WordFlow app icon."""
from PIL import Image, ImageDraw, ImageFont
import os

root = os.path.dirname(__file__)


def create_icon(width, height):
    image = Image.new('RGBA', (width, height), (37, 99, 235, 255))
    draw = ImageDraw.Draw(image)
    font_size = max(12, int(min(width, height) * 0.62))
    try:
        font = ImageFont.truetype("arialbd.ttf", font_size)
    except Exception:
        font = ImageFont.load_default()
    draw.text(
        (width // 2, height // 2),
        "W",
        fill="white",
        font=font,
        anchor="mm",
    )
    return image


# Replace every platform launcher icon while preserving its expected dimensions.
for current_root, _, files in os.walk(os.path.join(root, "apps")):
    for filename in files:
        lower = filename.lower()
        path = os.path.join(current_root, filename)
        if lower.endswith(".png") and (
            "icon" in lower or "launcher" in lower or lower == "favicon.png"
        ):
            with Image.open(path) as existing:
                width, height = existing.size
            create_icon(width, height).save(path, format="PNG")
        elif lower == "app_icon.ico":
            create_icon(256, 256).save(
                path,
                format="ICO",
                sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)],
            )

out = os.path.join(root, "app_icon.ico")
create_icon(256, 256).save(
    out,
    format="ICO",
    sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)],
)
print("WordFlow icons updated")
