# @New

Adds a brand-new method to the hooked Objective-C class at runtime via `class_addMethod`. The function **must** be annotated with `@objc` — the compiler uses the `@objc` method's type encoding as the single source of truth.

--- begin-snippet ---
## Definition

```swift
@New("dodoSetupMask")
@objc
private func dodoSetupMask() {
    target.view.layer.mask = cropFrame
}
```

## Requirements

| Rule | Reason |
|------|--------|
| Must be annotated with `@objc` | The `@objc` method provides the correct ObjC type encoding — no manual `"v@:"` strings needed |
| Must be inside a `@ClassHook` container | The hook container provides the `target` instance |
| Selector must be unique on the target class | `class_addMethod` fails if the selector already exists |

## Generated Code

The macro emits inline Objective-C runtime calls inside `activate()` — no Shook runtime dependency:

```swift
let imp_dodoSetupMask = imp_implementationWithBlock(block_dodoSetupMask)
if let m = class_getInstanceMethod(SBIconViewHook.self, sel_dodoSetupMask) {
    class_addMethod(cls, sel_dodoSetupMask, imp_dodoSetupMask, method_getTypeEncoding(m))
}
```

## Pitfalls

- If the target class (or any superclass) already responds to the selector, `class_addMethod` returns `NO` and the method is silently not added. Choose selectors that don't collide with UIKit/SpringBoard methods.
- The method is added at runtime when `activate()` is called. It won't be available during `+load` or static initializers.
--- end-snippet ---
