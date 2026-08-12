# @ClassHook

Defines a Swift class as a hook container for an Objective-C target class. Generates all the boilerplate: the target reference, an `Orig` inner struct for calling original implementations, IMP storage, and an `activate()` entry point.

--- begin-snippet ---
## Definition

```swift
@ClassHook("SBIconView", type: UIView.self)
class SBIconViewHook {
    @Hook("layoutSubviews")
    func hookLayoutSubviews() {
        orig.hookLayoutSubviews()
        target.alpha = 0.5
    }
}
```

## What Gets Generated

`@ClassHook` expands into:

```swift
class SBIconViewHook {
    public let target: UIView
    public var orig: Orig { Orig(target: target) }
    public required init(target: UIView) { self.target = target }

    public struct Orig {
        let target: UIView
        func hookLayoutSubviews() { ... }
    }

    nonisolated(unsafe) static var orig_hookLayoutSubviews_IMP: IMP?

    public static func activate() {
        guard let cls = NSClassFromString("SBIconView") else { return }
        // MSHookMessageEx for each @Hook method ...
    }
}
```

## Usage

Call `activate()` once during tweak initialization:

```swift
SBIconViewHook.activate()
```

Or wrap multiple hooks with [`@HookGroup`](HookGroup.md).
--- end-snippet ---
