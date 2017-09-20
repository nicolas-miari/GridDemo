//
//  ViewController.swift
//  GridDemo
//
//  Created by Nicolás Miari on 2017/09/20.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        guard let metalView = self.view as? MTKView else {
            fatalError("!!!")
        }
        self.renderer = Renderer(view: metalView)
    }
}
