# @Hook

Marks a function inside a `@ClassHook` container as a method swizzle. The macro is a marker — the real code generation happens in `@ClassHook`, which scans for `@Hook`-annotated functions and generates `MSHookMessageEx` calls.

--- begin-snippet ---
## Definition

```swift
@Hook("layoutSubviews")
func hookLayoutSubviews() {
    orig.hookLayoutSubviews()
    target.alpha = 0.5
}
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `selector` | The Objective-C selector to swizzle (e.g. `"layoutSubviews"`, `"viewDidAppear:"`) |

## Usage

- The function body replaces the original method implementation.
- Call `orig.<methodName>(...)` to invoke the original implementation.
- Access `target` to interact with the hooked instance.
- The function name is arbitrary — the selector is what matters.

> **Warning:** You must call `MSHookMessageEx` to swizzle the method. `@ClassHook` generates this automatically in `activate()`.
--- end-snippet ---
