import UIKit
import Shook
import @@PROJECTNAME@@C

@objc(Tweak)
@objcMembers
public class Tweak: NSObject {

    public static func setup() {
        AllHooks.activate()
    }
}
