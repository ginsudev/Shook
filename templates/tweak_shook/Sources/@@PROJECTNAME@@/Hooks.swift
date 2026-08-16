import UIKit
import Shook
import CydiaSubstrate

@HookGroup
struct AllHooks {
    @ClassHook("SBIconView", type: UIView.self)
    class SBIconViewHook {
        @Hook("layoutSubviews")
        func hookLayoutSubviews() {
            orig.hookLayoutSubviews()
            target.alpha = 0.5
        }
    }
}
