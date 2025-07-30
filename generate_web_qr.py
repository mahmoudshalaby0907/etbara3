import qrcode
from PIL import Image

# Create the web app URL (direct link)
web_app_url = "http://10.154.1.102:8000/web_app/"

# Generate QR code
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(web_app_url)
qr.make(fit=True)

# Create QR code image
qr_image = qr.make_image(fill_color="black", back_color="white")

# Save the QR code
qr_image.save("fapp_web_qr.png")

print("✅ Web App QR Code generated successfully!")
print(f"🌐 Web App URL: {web_app_url}")
print("📱 QR Code saved as: fapp_web_qr.png")
print("\n📋 Instructions:")
print("1. Scan the QR code with your phone's camera or QR scanner app")
print("2. The Flutter web app will open directly in your browser")
print("3. No download required - works on any device!")
print("4. All app features are available in the web version")
print("\n🎉 Perfect for demos and testing!") 