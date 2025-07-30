import qrcode
from PIL import Image

# Create the download URL (now working!)
download_url = "http://10.154.1.102:8000/apk_download.html"

# Generate QR code
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(download_url)
qr.make(fit=True)

# Create QR code image
qr_image = qr.make_image(fill_color="black", back_color="white")

# Save the QR code
qr_image.save("fapp_download_qr.png")

print("✅ QR Code generated successfully!")
print(f"🌐 Download URL: {download_url}")
print("📱 QR Code saved as: fapp_download_qr.png")
print("\n📋 Instructions:")
print("1. Scan the QR code with your phone's camera or QR scanner app")
print("2. The download page will open in your browser")
print("3. Click 'Download APK' to get the app")
print("4. Install the APK on your phone")
print("\n🎉 The server is now running and ready!") 