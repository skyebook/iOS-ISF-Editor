//
//  ViewController.swift
//  iOS ISF Editor
//
//  Created by Skye Book on 11/3/16.
//  Copyright © 2016 Skye Book. All rights reserved.
//

import UIKit
import SnapKit
import VVBasics
import VVBufferPool
import VVISFKit

class ViewController: UIViewController {
    
    var isfScene: ISFGLScene?
    let bufferView: VVBufferGLKView = VVBufferGLKView()
    
    var displayLink: CADisplayLink?
    
    let size = CGSize(width:2560, height:1280)
    
    let videoSource = VideoSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bufferView)
        bufferView.snp.makeConstraints {(make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        VVBufferPool.createGlobalVVBufferPool()
        isfScene = ISFGLScene(sharegroup: (VVBufferPool.globalVVBufferPool() as! VVBufferPool).sharegroup(), sized: size)
        isfScene!.useFile(Bundle.main.path(forResource: "sup", ofType: "fs")!)
        
        videoSource.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {() in
            print("starting displaylink")
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkCallback(displayLink:)))
            self.displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        })
        
    }
    
    func renderOnBuffer(buffer: VVBuffer) -> VVBuffer? {
        guard let isfScene = isfScene else {
            return nil
        }
        
        //isfScene.setBuffer(buffer, forInputImageKey: "inputImage")
        isfScene.setFilterInputImageBuffer(buffer)
        
        // TODO: Some day, set input controls here (see ISFController#renderFXOnThisBuffer, which is what this function is based on)
        
        return isfScene.allocAndRender(toBufferSized: size, prefer2DTex: true)
        
        //return nil
    }
    
    func displayLinkCallback(displayLink: CADisplayLink) {
        guard let videoBuffer = videoSource.allocBuffer(nextDisplayTime: displayLink.timestamp + displayLink.duration) else {
            // not ready yet
            return
        }
        
        //bufferView.draw(videoBuffer)
        
        if let renderedShaderBuffer = renderOnBuffer(buffer: videoBuffer) {
            bufferView.draw(renderedShaderBuffer)
        }
        
//        var buffer = isfScene!.allocAndRender(toBufferSized: size)
//        bufferView.draw(buffer)
//        buffer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

