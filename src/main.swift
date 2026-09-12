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
