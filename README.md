# Shook

Swift macro framework for Objective-C method hooking. Built for jailbreak tweak developers who prefer writing Swift.

## Quick Start

```swift
import Shook
import CydiaSubstrate

@HookGroup
struct AllHooks {
    @ClassHook("SBIconView", type: UIView.self)
    class SBIconViewHook {
        @Property var tapCount: Int = 0

        @Hook("layoutSubviews")
        func hookLayoutSubviews() {
            orig.hookLayoutSubviews()
            target.alpha = 0.5
        }

        @New("shake")
        @objc
        func shake() {
            target.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
}

// In your tweak constructor:
AllHooks.activate()
```

## Macros

| Macro | Description |
|-------|-------------|
| [`@ClassHook`](docs/ClassHook.md) | Defines a hook container. Generates target, `orig`, IMP storage, and `activate()`. |
| [`@Hook`](docs/Hook.md) | Marks a function as a method swizzle. Calls the original via `orig`. |
| [`@New`](docs/New.md) | Adds a new method to the target class via `class_addMethod`. Requires `@objc`. |
| [`@Property`](docs/Property.md) | Adds an associated-object property on the hooked instance. |
| [`@HookGroup`](docs/HookGroup.md) | Groups multiple `@ClassHook` types and generates a single `activate()`. |

## Requirements

- [Theos](https://theos.dev)
- [Xcode](https://developer.apple.com/xcode/) (any version with Swift 5.10+)
- [Cydia Substrate](http://www.cydiasubstrate.com) (bundled with Theos)
- iOS 14+ deployment target

## Installation

Shook is a Theos **module**. Clone it into your Theos module directory:

```bash
git clone https://github.com/ginsudev/Shook.git $THEOS/mod/shook
```

The framework is **compile-time only** — no Shook runtime dependency on the device. Macros expand inline into plain Objective-C runtime calls, and the macro plugin + device module are built automatically (and cached) on first use.

## Integration

Enable the module in your tweak's Makefile:

```makefile
MODULES = shook
```

…or globally, in `~/.theosrc`:

```makefile
export THEOS_AUTOLOAD_MODULES = shook
```

Then just `import Shook` in your Swift sources. No `-F` flags, no `-load-plugin-executable` — the module wires everything up when it detects Swift files.

## License

MIT — see [LICENSE](LICENSE).
