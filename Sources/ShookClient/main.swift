#if canImport(UIKit)
import Foundation
import UIKit
import ObjectiveC
import Shook

@ClassHook("SBIconView", type: UIView.self)
class HookSBIconView {
    @Property var example: String = "Test"
    
    @Hook("viewWillAppear:")
    func hookViewWillAppear(_ animated: Bool) {
        orig.hookViewWillAppear(animated)
        target.alpha = 0.5
        print("Hooked viewWillAppear on: \(target)")
    }
    
    @New("test")
    @objc func abc() {
        
    }
}

@HookGroup
struct AllHooks {
    @ClassHook("SBIconView", type: UIView.self)
    class SBIconViewHook {
        @Hook("layoutSubviews")
        func hookLayoutSubviews() {
            orig.hookLayoutSubviews()
            target.alpha = 0.3
        }
    }
    
    @ClassHook("SpringBoard", type: UIApplication.self)
    class SpringBoardHook {
        @Hook("applicationDidFinishLaunching:")
        func hookApplicationDidFinishLaunching(_ application: UIApplication) {
            orig.hookApplicationDidFinishLaunching(application)
        }
    }
}

// Single entry point replacing all individual .activate() calls
AllHooks.activate()
#endif
