//
//  Renderer.swift
//  GridDemo
//
//  Created by Nicolás Miari on 2017/09/20.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Metal
import simd
import MetalKit

struct Constants {
    var modelViewProjectionMatrix = matrix_identity_float4x4
    var tintColor = float4(1, 1, 1, 1)
    //var normalMatrix = matrix_identity_float3x3
}

@objc
class Renderer: NSObject {

    weak var view: MTKView!

    var constants = Constants()
    
    let quad: Quad

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    let sampler: MTLSamplerState
    let texture: MTLTexture

    init?(view: MTKView) {
        self.view = view

        self.view.sampleCount = 4
        self.view.clearColor = MTLClearColorMake(1, 1, 1, 1)
        self.view.colorPixelFormat = .bgra8Unorm
        self.view.depthStencilPixelFormat = .depth32Float

        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            self.device = defaultDevice
        } else {
            print("Metal is not supported")
            return nil
        }
        self.commandQueue = device.makeCommandQueue()

        do {
            self.renderPipelineState = try Renderer.createRenderPipeline(withDevice: device, view: view)
        } catch {
            return nil
        }

        do {
            self.texture = try Renderer.buildTexture(name: "Flag", device: device)
        } catch {
            return nil
        }

        self.depthStencilState = Renderer.buildDepthStencilState(withDevice: device, compareFunction: .less, isWriteEnabled: true)

        self.sampler = Renderer.buildSamplerState(withDevice: device, addressMode: .clampToEdge, filter: .linear)

        self.quad = Quad(sideLength: 32, device: device)

        super.init()

        view.delegate = self
        view.device = device
    }

    // Initialization Support

    static func createRenderPipeline(withDevice device: MTLDevice, view: MTKView) throws -> MTLRenderPipelineState {

        let library = device.newDefaultLibrary()!

        let vertexFunction = library.makeFunction(name: "sprite_vertex_transform")
        let fragmentFunction = library.makeFunction(name: "sprite_fragment_textured")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.label = "Render Pipeline"
        pipelineDescriptor.sampleCount = view.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    static func buildTexture(name: String, device: MTLDevice) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        let asset = NSDataAsset.init(name: name)
        if let data = asset?.data {
            return try textureLoader.newTexture(with: data, options: [:])
        } else {
            fatalError("Could not load image \(name) from an asset catalog in the main bundle")
        }
    }

    static func buildSamplerState(
        withDevice device: MTLDevice,
        addressMode: MTLSamplerAddressMode,
        filter: MTLSamplerMinMagFilter) -> MTLSamplerState {

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = addressMode
        samplerDescriptor.tAddressMode = addressMode
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = filter
        samplerDescriptor.magFilter = filter

        return device.makeSamplerState(descriptor: samplerDescriptor)
    }

    static func buildDepthStencilState(
        withDevice device: MTLDevice,
        compareFunction: MTLCompareFunction,
        isWriteEnabled: Bool) -> MTLDepthStencilState {

        let desc = MTLDepthStencilDescriptor()
        desc.depthCompareFunction = compareFunction
        desc.isDepthWriteEnabled = isWriteEnabled

        return device.makeDepthStencilState(descriptor: desc)
    }

    // Operation

    func render(_ view: MTKView) {

        let commandBuffer = commandQueue.makeCommandBuffer()

        defer {
            commandBuffer.commit()
        }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        renderEncoder.pushDebugGroup("Draw Grid")
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.none)
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(renderPipelineState)

        renderEncoder.setVertexBuffer(quad.vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, at: 1)
        renderEncoder.setFragmentTexture(texture, at: 0)
        renderEncoder.setFragmentSamplerState(sampler, at: 0)

        renderEncoder.drawIndexedPrimitives(
            type: quad.primitiveType,
            indexCount: quad.indexCount,
            indexType: quad.indexType,
            indexBuffer: quad.indexBuffer,
            indexBufferOffset: 0)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // respond to resize
    }

    @objc(drawInMTKView:)
    func draw(in metalView: MTKView) {
        render(metalView)
    }
}
