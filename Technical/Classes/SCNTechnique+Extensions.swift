//
//  SCNTechnique+Extensions.swift
//  Pods-Technical_Example
//
//  Created by Tomoya Hirano on 2019/01/02.
//

import SceneKit

extension SCNTechnique {
  public convenience init?(_ configuration: Configuration) {
    self.init(dictionary: configuration.toDictionary)
  }
}

extension SCNTechnique {
  public struct Configuration {
    public let filters: [FilterType]
    public let symbols: [ShaderSymbolable]
    
    public init(filters: [FilterType], symbols: [ShaderSymbolable] = []) {
      self.filters = filters
      self.symbols = symbols
    }
  }
}

extension SCNTechnique.Configuration {
  fileprivate var toDictionary: [String : Any] {
    var dictionary: [String : Any] = [:]
    dictionary["sequence"] = filters.compactMap({ $0.name })
    var passes: [String : Any] = [:]
    filters.forEach({
      passes[$0.name] = $0.toDictionary
    })
    dictionary["passes"] = passes
    dictionary["symbols"] = symbols.reduce(into: [String : Any](), { $0[$1.name] = $1.toDictionary })
    return dictionary
  }
}

public enum Draw: String {
  case scene = "DRAW_SCENE"
  case node = "DRAW_NODE"
  case quad = "DRAW_QUAD"
}

public protocol FilterType {
  var name: String { get }
  var toDictionary: [String : Any] { get }
}

public struct MetalFilter: FilterType {
  public let name: String
  public let vertexShader: String
  public let fragmentShader: String
  public let draw: Draw
  public let inputs: [Input]
  public let outputs: [Output]
  
  public init(name: String,
              vertexShader: String,
              fragmentShader: String,
              draw: Draw,
              inputs: [Input],
              outputs: [Output]) {
    self.name = name
    self.vertexShader = vertexShader
    self.fragmentShader = fragmentShader
    self.draw = draw
    self.inputs = inputs
    self.outputs = outputs
  }
}

extension MetalFilter {
  public var toDictionary: [String : Any] {
    return [
      "metalVertexShader" : vertexShader,
      "metalFragmentShader" : fragmentShader,
      "draw" : draw.rawValue,
      "inputs" : inputs.reduce(into: [String:Any](), { $0[$1.key] = $1.value.string }),
      "outputs" : outputs.reduce(into: [String:Any](), { $0[$1.key.rawValue] = $1.value.string }),
    ]
  }
}

public struct Input {
  public let key: String
  public let value: Input.Value
  
  public init(key: String, value: Input.Value) {
    self.key = key
    self.value = value
  }
}

public struct Output {
  public let key: Output.Key
  public let value: Output.Value
  
  public init(key: Output.Key, value: Output.Value) {
    self.key = key
    self.value = value
  }
}

extension Input {
  public enum Value {
    case custom(String)
    case symbol(ShaderSymbolable)
    case color
    
    var string: String {
      switch self {
      case .custom(let value): return value
      case .symbol(let value): return value.name
      case .color: return "COLOR"
      }
    }
  }
}

extension Output {
  public enum Key: String {
    case color
    case depth
    case stencil
  }
  
  public enum Value {
    case custom(String)
    case color
    
    var string: String {
      switch self {
      case .custom(let value): return value
      case .color: return "COLOR"
      }
    }
  }
}

public protocol ShaderSymbolable {
  var name: String { get }
  var type: ShaderSymbolType { get }
  var toDictionary: [String : Any] { get }
}

public struct ImageSymbol: ShaderSymbolable {
  public let name: String
  public let image: String
  public let type: ShaderSymbolType
  
  public init(name: String, image: String, type: ShaderSymbolType) {
    self.name = name
    self.image = image
    self.type = type
  }
  
  public var toDictionary: [String : Any] {
    return [
      "image" : image,
      "type" : type.rawValue
    ]
  }
}

public enum ShaderSymbolType: String {
  case float
  case vec2
  case vec3
  case vec4
  case mat4
  case int
  case ivec2
  case ivec3
  case ivec4
  case mat3
  case sampler2D
  case none
}
