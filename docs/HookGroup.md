# @HookGroup

Groups multiple `@ClassHook` types inside a struct, enum, or class and generates a single `activate()` entry point that chains all nested hook classes in declaration order.

--- begin-snippet ---
## Definition

```swift
@HookGroup
struct AllHooks {
    @ClassHook("SBIconView", type: UIView.self)
    class SBIconViewHook {
        @Hook("layoutSubviews")
        func hookLayoutSubviews() { ... }
    }

    @ClassHook("SpringBoard", type: UIApplication.self)
    class SpringBoardHook {
        @Hook("applicationDidFinishLaunching:")
        func hook(_ app: UIApplication) { ... }
    }
}
```

## Generated Code

```swift
struct AllHooks {
    // ... nested hook classes expanded by @ClassHook ...

    public static func activate() {
        SBIconViewHook.activate()
        SpringBoardHook.activate()
    }
}
```

## Usage

Replace individual `activate()` calls with a single line:

```swift
// Before
CSCombinedListViewControllerHook.activate()
NCNotificationStructuredListViewControllerHook.activate()
SpringBoardHook.activate()
// ... 15 more lines

// After
AllHooks.activate()
```

The hooks are activated in the order they appear inside the `@HookGroup` body.
--- end-snippet ---
