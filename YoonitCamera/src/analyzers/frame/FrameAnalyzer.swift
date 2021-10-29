/*
 * ██╗   ██╗ ██████╗  ██████╗ ███╗   ██╗██╗████████╗
 * ╚██╗ ██╔╝██╔═══██╗██╔═══██╗████╗  ██║██║╚══██╔══╝
 *  ╚████╔╝ ██║   ██║██║   ██║██╔██╗ ██║██║   ██║
 *   ╚██╔╝  ██║   ██║██║   ██║██║╚██╗██║██║   ██║
 *    ██║   ╚██████╔╝╚██████╔╝██║ ╚████║██║   ██║
 *    ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝
 *
 * https://yoonit.dev - about@yoonit.dev
 *
 * iOS Yoonit Camera
 * The most advanced and modern Camera module for iOS with a lot of awesome features
 *
 * Haroldo Teruya & Márcio Bruffato @ 2020-2021
 */

import AVFoundation
import UIKit

/**
 This class is responsible to handle the operations related with the frame capture.
 */
class FrameAnalyzer: NSObject {
            
    public var numberOfImages = 0
    public var cameraEventListener: CameraEventListenerDelegate?
    public var start = false {
        didSet {
            if !self.start {
                self.numberOfImages = 0                
            }            
        }
    }
    
    private let MAX_NUMBER_OF_IMAGES = 25
    private var lastTimestamp = Date().currentTimeMillis()
                
    func frameCaptured(imageBuffer: CVPixelBuffer) {
        if !self.start || !captureOptions.saveImageCaptured {
            return
        }
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > captureOptions.timeBetweenImages {
            self.lastTimestamp = currentTimestamp
            
            DispatchQueue.global(qos: .userInitiated).async {
                var image: UIImage = imageBuffer.toUIImage()
                
                if captureOptions.cameraLens == .front {
                    image = image.withHorizontallyFlippedOrientation()
                }
                                        
                let fileURL = fileURLFor(index: self.numberOfImages)
                let filePath = try! save(
                    image: image,
                    fileURL: fileURL
                )
                
                let (
                    darkness,
                    lightness,
                    sharpness
                ) = ImageQualityController.processImage(imageBuffer: imageBuffer)
            
                DispatchQueue.main.async {
                    self.handleEmitImageCaptured(
                        filePath: filePath,
                        darkness: darkness,
                        lightness: lightness,
                        sharpness: sharpness
                    )
                }
            }
        }
    }
    
    /**
     Handle emit frame file saved and the quality of the image;
     
     - Parameter imagePath: image file path.
     - Parameter darkness: image darkness classification.
     - Parameter lightness: image lighness classification.
     - Parameter sharpness: image sharpness classification.
     */
    func handleEmitImageCaptured(
        filePath: String,
        darkness: NSNumber?,
        lightness: NSNumber?,
        sharpness: NSNumber?
    ) {
        
        // process frame number of images.
        if (captureOptions.numberOfImages > 0) {
            if (self.numberOfImages < captureOptions.numberOfImages) {
                self.numberOfImages += 1
                self.cameraEventListener?.onImageCaptured(
                    "frame",
                    self.numberOfImages,
                    captureOptions.numberOfImages,
                    filePath,
                    darkness,
                    lightness,
                    sharpness
                )
                return
            }
            
            self.start = false
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        // process frame unlimited.
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onImageCaptured(
            "frame",
            self.numberOfImages,
            captureOptions.numberOfImages,
            filePath,
            darkness,
            lightness,
            sharpness
        )
    }
}


