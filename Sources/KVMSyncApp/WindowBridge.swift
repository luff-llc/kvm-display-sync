import SwiftUI

struct WindowBridge: NSViewRepresentable {
    let delegate: AppDelegate
    func makeNSView(context: Context) -> WindowAnchorView {
        let view = WindowAnchorView()
        view.appDelegate = delegate
        return view
    }
    func updateNSView(_ nsView: WindowAnchorView, context: Context) { }
}
