//
//  VideoSource.swift
//  iOS ISF Editor
//
//  Created by Skye Book on 11/3/16.
//  Copyright © 2016 Skye Book. All rights reserved.
//

import AVFoundation
import VVBufferPool

class VideoSource: NSObject {
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerItemOutput: AVPlayerItemVideoOutput?
    var looper: AVPlayerLooper?
    
    var textureCache: CVOpenGLESTextureCache?

    func start() {
        
        let context = (VVBufferPool.globalVVBufferPool() as! VVBufferPool).context()
        
        CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context!, nil, &textureCache);
        
        guard let videoPath = Bundle.main.path(forResource: "360_0014", ofType: "mp4") else {
            print("fail")
            return
        }
        
        playerItem = AVPlayerItem(url: URL(fileURLWithPath:videoPath))
        //kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_422YpCbCr8,
        
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferIOSurfacePropertiesKey as String: NSDictionary(),
            kCVPixelBufferOpenGLESCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferOpenGLESTextureCacheCompatibilityKey as String: NSNumber(value: true)]
        playerItemOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        
        
        player = AVPlayer(playerItem: playerItem!)
        
        playerItem!.add(playerItemOutput!)
        
        //player = AVQueuePlayer()
        //looper = AVPlayerLooper(player: player, templateItem: playerItem!)
        player?.play()
    }
    
    func allocBuffer(nextDisplayTime: CFTimeInterval) -> VVBuffer? {
        guard let playerItemOutput = playerItemOutput,
        let bufferPool = VVBufferPool.globalVVBufferPool() as? VVBufferPool,
        let textureCache = textureCache else {
            return nil
        }
        
        
        let itemTime = playerItemOutput.itemTime(forHostTime: nextDisplayTime)
        
        guard playerItemOutput.hasNewPixelBuffer(forItemTime: itemTime),
        let pb = playerItemOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
            return nil
        }
        
        let width = GLsizei(CVPixelBufferGetWidth(pb))
        let height = GLsizei(CVPixelBufferGetHeight(pb))
        
        var texture_: CVOpenGLESTexture?
        let result = CVOpenGLESTextureCacheCreateTextureFromImage(nil, textureCache, pb, nil, GLenum(GL_TEXTURE_2D), GL_RGBA, width, height, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), 0, &texture_)
        guard result == kCVReturnSuccess else {
            print("Failed to create GL Texture. Result: \(result)")
            return nil
        }
        
        guard let texture = texture_ else {
            print("fuck this shit")
            return nil
        }
        
        let textureName = CVOpenGLESTextureGetName(texture)
        let buffer = bufferPool.allocBuffer(forCVGLTex: texture)
        buffer?.flipped = true
        return buffer
    }
}
