#!/usr/bin/env python3
import qrcode
from PIL import Image
import os

def generate_install_qr():
    # The URL where your install page will be hosted
    # You can change this to your actual hosting URL
    install_url = "https://mahmoudshalaby0907.github.io/etbara3/install_app.html"
    
    # Create QR code
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(install_url)
    qr.make(fit=True)
    
    # Create image
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save the QR code
    img.save("etbara3_install_qr.png")
    
    print("✅ QR Code generated successfully!")
    print(f"📱 QR Code saved as: etbara3_install_qr.png")
    print(f"🔗 Install URL: {install_url}")
    print("\n📋 Instructions:")
    print("1. Host the install_app.html file on GitHub Pages or any web server")
    print("2. Make sure app-release.apk is in the same directory")
    print("3. Share the QR code with users")
    print("4. Users scan QR code → Download APK → Install app")

if __name__ == "__main__":
    generate_install_qr() 