#!/bin/bash
set -e
# Fix quarantine
xattr -cr "$0" 2>/dev/null
cd ~/Downloads

echo "Building Crypt..."

# Find assets
if [ -f ~/Downloads/vault.png ]; then VAULT=~/Downloads/vault.png
elif [ -f ~/Desktop/vault.png ]; then VAULT=~/Desktop/vault.png
else echo "Missing vault.png - download it to Downloads"; exit 1; fi

if [ -f ~/Downloads/monero-monitor.html ]; then HTML=~/Downloads/monero-monitor.html
elif [ -f ~/Desktop/monero-monitor.html ]; then HTML=~/Desktop/monero-monitor.html
else echo "Missing monero-monitor.html - download it to Downloads"; exit 1; fi

# 1. Icon
rm -rf icon.iconset Vault.icns
mkdir icon.iconset
sips -z 1024 1024 "$VAULT" --out icon.iconset/icon_512x512@2x.png > /dev/null
sips -z 512 512 "$VAULT" --out icon.iconset/icon_512x512.png > /dev/null
sips -z 256 256 "$VAULT" --out icon.iconset/icon_256x256@2x.png > /dev/null
sips -z 128 128 "$VAULT" --out icon.iconset/icon_128x128.png > /dev/null
iconutil -c icns icon.iconset -o Vault.icns
rm -rf icon.iconset

# 2. Build Swift app that loads HTML from INSIDE bundle
rm -rf /tmp/CryptBuild
mkdir -p /tmp/CryptBuild

cat > /tmp/CryptBuild/main.swift <<'SWIFT'
import Cocoa
import WebKit
class AppDelegate: NSObject, NSApplicationDelegate {
 let window = NSWindow(contentRect: NSMakeRect(0,0,1100,720), styleMask: [.titled,.closable,.miniaturizable,.resizable], backing: .buffered, defer: false)
 func applicationDidFinishLaunching(_ aNotification: Notification) {
  window.center()
  window.title = "Crypt"
  window.minSize = NSSize(width: 900, height: 600)
  let web = WKWebView(frame: window.contentView!.bounds)
  web.autoresizingMask = [.width,.height]
  if let htmlPath = Bundle.main.path(forResource: "monero-monitor", ofType: "html") {
    let url = URL(fileURLWithPath: htmlPath)
    web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
  }
  window.contentView?.addSubview(web)
  window.makeKeyAndOrderFront(nil)
  NSApp.activate(ignoringOtherApps: true)
 }
}
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
SWIFT

swiftc /tmp/CryptBuild/main.swift -o /tmp/CryptBuild/Crypt -framework Cocoa -framework WebKit

mkdir -p "/tmp/CryptBuild/Crypt.app/Contents/MacOS"
mkdir -p "/tmp/CryptBuild/Crypt.app/Contents/Resources"
mv /tmp/CryptBuild/Crypt "/tmp/CryptBuild/Crypt.app/Contents/MacOS/"
cp Vault.icns "/tmp/CryptBuild/Crypt.app/Contents/Resources/AppIcon.icns"
cp "$HTML" "/tmp/CryptBuild/Crypt.app/Contents/Resources/monero-monitor.html"

cat > "/tmp/CryptBuild/Crypt.app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>Crypt</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleIdentifier</key><string>com.vault.crypt</string>
<key>CFBundleName</key><string>Crypt</string>
<key>CFBundleDisplayName</key><string>Crypt</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1.0</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
</dict></plist>
PLIST

# Make runnable from Downloads
rm -rf ~/Downloads/Crypt.app
cp -R "/tmp/CryptBuild/Crypt.app" ~/Downloads/
xattr -cr ~/Downloads/Crypt.app

echo "Built ~/Downloads/Crypt.app - testing run from Downloads..."
open ~/Downloads/Crypt.app
sleep 1

# Install directly to /Applications (asks for password once)
echo "Installing to /Applications (will ask for password)..."
osascript -e 'do shell script "rm -rf /Applications/Crypt.app && cp -R ~/Downloads/Crypt.app /Applications/ && xattr -cr /Applications/Crypt.app" with administrator privileges'

echo "Done - Crypt is in /Applications and runnable from Downloads"
open /Applications/Crypt.app
