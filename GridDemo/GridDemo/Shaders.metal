//
//  Shaders.metal
//  GridDemo
//
//  Created by Nicolás Miari on 2017/09/20.
//  Copyright (c) 2017 Nicolás Miari. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float4x4 modelViewProjectionMatrix;
    float4 tintColor;
};

struct VertexIn {
    //packed_float4 position [[ attribute(0) ]];
    //packed_float2 texCoords [[ attribute(1) ]];
    float4 position [[ attribute(0) ]];
    float2 texCoords [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
};

/// Vertex Shader for Sprites
///
vertex VertexOut sprite_vertex_transform(device VertexIn *vertices [[buffer(0)]],
                                         constant Constants &uniforms [[buffer(1)]],
                                         uint vertexId [[vertex_id]]) {

    float4 modelPosition = vertices[vertexId].position;

    VertexOut out;

    out.position = uniforms.modelViewProjectionMatrix * modelPosition;
    out.texCoords = vertices[vertexId].texCoords;

    return out;
}

/// Fragment Shader for Sprites
///
fragment half4 sprite_fragment_textured(
        VertexOut fragmentIn [[stage_in]],
        texture2d<float, access::sample> tex2d [[texture(0)]],
        sampler sampler2d [[sampler(0)]]){

    half4 surfaceColor = half4(tex2d.sample(sampler2d, fragmentIn.texCoords).rgba);

    return surfaceColor;
}

/*
#include <metal_stdlib>

using namespace metal;

struct VertexInOut
{
    float4  position [[position]];
    float4  color;
};

vertex VertexInOut passThroughVertex(uint vid [[ vertex_id ]],
                                     constant packed_float4* position  [[ buffer(0) ]],
                                     constant packed_float4* color    [[ buffer(1) ]])
{
    VertexInOut outVertex;
    
    outVertex.position = position[vid];
    outVertex.color    = color[vid];
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};*/
