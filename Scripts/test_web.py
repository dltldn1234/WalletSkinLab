"""Run with Playwright, Pillow and Chromium installed."""
from pathlib import Path
from io import BytesIO
from tempfile import TemporaryDirectory
from shutil import which
from playwright.sync_api import sync_playwright
from PIL import Image

root = Path(__file__).resolve().parents[1]
with sync_playwright() as playwright, TemporaryDirectory() as temporary:
    browser = playwright.chromium.launch(executable_path=which("chromium"), args=["--no-sandbox"])
    page = browser.new_page(viewport={"width":390,"height":844})
    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))
    page.goto((root / "Web/WalletSkinLab.html").as_uri())
    page.wait_for_function("Object.values(images).every(i=>i.complete && i.naturalWidth)")
    for style in ["gold","black","platinum","midnight","graphite","custom"]:
        if style == "custom":
            buffer = BytesIO()
            Image.new("RGB",(120,240),"red").save(buffer,"PNG")
            page.locator("#imageFile").set_input_files({"name":"portrait.png","mimeType":"image/png","buffer":buffer.getvalue()})
            page.locator("#contain").click()
        else:
            page.locator(f'button[data-id="{style}"]').click()
        with page.expect_download() as event:
            page.locator("#export").click()
        target = Path(temporary) / event.value.suggested_filename
        event.value.save_as(target)
        with Image.open(target) as image:
            image.load()
            assert image.format == "PNG" and image.size == (1536,969)
            if style == "custom":
                assert image.getpixel((768,484))[:3] == (255,0,0)
                assert image.getpixel((100,484))[:3] == (11,15,22)
            else:
                assert len(image.convert("RGB").resize((16,16)).getcolors()) > 4
        print(style, "PNG OK")
    assert not errors, errors
    browser.close()
