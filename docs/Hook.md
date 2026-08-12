# @Hook

Marks a function inside a `@ClassHook` container as a method swizzle. The macro is a marker — the real code generation happens in `@ClassHook`, which scans for `@Hook`-annotated functions and generates `MSHookMessageEx` calls.

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
- The function name can be anything, but the selector string is important as it gives the target method reference to Shook.

> **Warning:** You must `import CydiaSubstrate` at the top of the file as Shook generates code that calls `MSHookMessageEx` to swizzle the method.

