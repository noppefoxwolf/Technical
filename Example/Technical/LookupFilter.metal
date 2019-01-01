//
//  LookupFilter.metal
//  Technical_Example
//
//  Created by Tomoya Hirano on 2019/01/01.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
//#include "OperationShaderTypes.h"
using namespace metal;

#include <SceneKit/scn_metal>

typedef struct {
  float intensity;
} IntensityUniform;

struct VertexInput {
  float4 position [[ attribute(SCNVertexSemanticPosition) ]];
  float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

struct VertexOut {
  float4 position [[position]];
  float2 texcoord;
};

vertex VertexOut oneInputVertex(VertexInput in [[stage_in]])
{
  VertexOut out;
  out.position = in.position;
  out.texcoord =  float2((in.position.x + 1.0) * 0.5 , (in.position.y + 1.0) * -0.5);
  return out;
}

fragment half4 lookupFragment(VertexOut fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              texture2d<half> inputTexture2 [[texture(1)]],
                              constant IntensityUniform& uniform [[ buffer(1) ]])
{
  /*
  constexpr sampler samp = sampler(coord::normalized, address::repeat, filter::nearest);
  constexpr half3 weights = half3(0.2126, 0.7152, 0.0722);
  
  half4 color = inputTexture.sample(samp, fragmentInput.texcoord);
  color.rgb = half3(dot(color.rgb, weights));
  
  return color;
  */
  constexpr sampler quadSampler = sampler(coord::normalized, address::repeat, filter::nearest);
  half4 base = inputTexture.sample(quadSampler, fragmentInput.texcoord);
  
  half blueColor = base.b * 63.0h;
  
  half2 quad1;
  quad1.y = floor(floor(blueColor) / 8.0h);
  quad1.x = floor(blueColor) - (quad1.y * 8.0h);
  
  half2 quad2;
  quad2.y = floor(ceil(blueColor) / 8.0h);
  quad2.x = ceil(blueColor) - (quad2.y * 8.0h);
  
  float2 texPos1;
  texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
  texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
  
  float2 texPos2;
  texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
  texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
  
  constexpr sampler quadSampler3;
  half4 newColor1 = inputTexture2.sample(quadSampler3, texPos1);
  constexpr sampler quadSampler4;
  half4 newColor2 = inputTexture2.sample(quadSampler4, texPos2);
  
  half4 newColor = mix(newColor1, newColor2, fract(blueColor));
  
  return half4(mix(base, half4(newColor.rgb, base.w), half(uniform.intensity)));
}
