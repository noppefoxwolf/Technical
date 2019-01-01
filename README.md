<h1 align="center">
Technical
<br>
</h1>

## Usage

```swift
let lutSymbol = ImageSymbol(name: "lutSymbol", image: "lookup_amatorka.png", type: .sampler2D)
let input = Input(key: "inputTexture", value: .color)
let inputLUT = Input(key: "inputTexture2", value: .symbol(lutSymbol))
let output = Output(key: .color, value: .color)
let filter = MetalFilter(name: "apply_filter",
vertexShader: "oneInputVertex",
fragmentShader: "lookupFragment",
draw: .quad,
inputs: [input, inputLUT],
outputs: [output])
let config = SCNTechnique.Configuration(filters: [filter], symbols: [lutSymbol])
scnView.technique = SCNTechnique(config)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Technical is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Technical'
```

## Author

noppefoxwolf, noppelabs@gmail.com

## License

Technical is available under the MIT license. See the LICENSE file for more info.
