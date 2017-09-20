//
//  Grid.swift
//  GridDemo
//
//  Created by Nicolás Miari on 2017/09/20.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Metal
import simd

struct Vertex {
    var position = float4(x: 0, y: 0, z: 0, w: 1)
    var textureCoordinate = float2(x: 0, y: 0)
}

class Quad {

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount: Int
    let indexType: MTLIndexType
    let primitiveType: MTLPrimitiveType


    init(sideLength: Float, device: MTLDevice) {

        self.primitiveType = .triangle

        var vertexData = [Vertex]()

        var topLeft = Vertex()
        topLeft.position.x = 0
        topLeft.position.y = 0
        topLeft.position.z = 0.5
        topLeft.textureCoordinate.x = 0
        topLeft.textureCoordinate.y = 0
        vertexData.append(topLeft)

        var bottomLeft = Vertex()
        bottomLeft.position.x = 0
        bottomLeft.position.y = sideLength
        bottomLeft.position.z = 0.5
        bottomLeft.textureCoordinate.x = 0
        bottomLeft.textureCoordinate.y = 1
        vertexData.append(bottomLeft)

        var topRight = Vertex()
        topRight.position.x = sideLength
        topRight.position.y = 0
        topRight.position.z = 0.5
        topRight.textureCoordinate.x = 1
        topRight.textureCoordinate.y = 0
        vertexData.append(topRight)

        var bottomRight = Vertex()
        bottomRight.position.x = sideLength
        bottomRight.position.y = sideLength
        bottomRight.position.z = 0.5
        bottomRight.textureCoordinate.x = 1
        bottomRight.textureCoordinate.y = 1
        vertexData.append(bottomRight)

        for vertex in vertexData {
            Swift.print(vertex)
        }

        let vertexBufferSize = vertexData.count * MemoryLayout<Vertex>.stride
        self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: [])

        var indexData = [UInt32]()

        // First triangle: Top left, bottom left, top right (CCW)
        indexData.append(0)
        indexData.append(1)
        indexData.append(2)

        // Second triangle: top right, bottom left, bottom right (CCW)
        indexData.append(2)
        indexData.append(1)
        indexData.append(3)

        for index in indexData {
            Swift.print(index)
        }

        self.indexType = .uint32
        self.indexCount = indexData.count

        let indexBufferSize = indexData.count * MemoryLayout<UInt32>.stride
        self.indexBuffer = device.makeBuffer(bytes: indexData, length: indexBufferSize, options: [])
    }
}
