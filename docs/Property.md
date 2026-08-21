# @Property

Adds an associated object property to the hooked instance. Generates a storage key and get/set accessors backed by `objc_getAssociatedObject` / `objc_setAssociatedObject`.

## Definition

```swift
@Property var counter: Int = 0
@Property(.OBJC_ASSOCIATION_RETAIN) var delegate: SomeDelegate?
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `policy` | `.OBJC_ASSOCIATION_RETAIN_NONATOMIC` | The `objc_AssociationPolicy` for the associated object |

Available policies: `.OBJC_ASSOCIATION_ASSIGN`, `.OBJC_ASSOCIATION_RETAIN_NONATOMIC`, `.OBJC_ASSOCIATION_RETAIN`, `.OBJC_ASSOCIATION_COPY_NONATOMIC`, `.OBJC_ASSOCIATION_COPY`

## Generated Code

For `@Property var example: String = "Test"`, the macro generates:

```swift
private static var exampleKey: UInt8 = 0

var example: String {
    get {
        if let existing = objc_getAssociatedObject(target, &Self.exampleKey) as? String {
            return existing
        }
        let newValue: String = "Test"
        objc_setAssociatedObject(target, &Self.exampleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newValue
    }
    set {
        objc_setAssociatedObject(target, &Self.exampleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
```

## Usage

Access via `target` context inside `@Hook` or `@New` methods:

```swift
@Hook("viewDidLoad")
func hookViewDidLoad() {
    orig.hookViewDidLoad()
    self.counter += 1            // reads/writes associated object on target
    target.setValue(counter, forKey: "tag")
}
```

> **Warning:** Using `.OBJC_ASSOCIATION_ASSIGN` creates a dangling pointer if the stored object is deallocated — it does **not** behave like a Swift `weak` reference. For weak semantics, store a wrapper that holds a weak reference and retain the wrapper with `.OBJC_ASSOCIATION_RETAIN_NONATOMIC`.

