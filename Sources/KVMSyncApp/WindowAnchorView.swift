import AppKit

final class WindowAnchorView: NSView {
    weak var appDelegate: AppDelegate?
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window { appDelegate?.track(window) }
    }
}
