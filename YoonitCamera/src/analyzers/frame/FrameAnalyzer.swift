//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya @ Cyberlabs AI 2020                              |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//


import AVFoundation
import UIKit
import Vision

/**
 This class is responsible to handle the operations related with the frame capture.
 */
class FrameAnalyzer: NSObject {
    
    private let MAX_NUMBER_OF_IMAGES = 25
    
    public var cameraEventListener: CameraEventListenerDelegate?
        
    private var lastTimestamp = Date().currentTimeMillis()
    private var started = false
    public var numberOfImages = 0
        
    /**
     Start frame analyzer to capture frame.
     */
    func start() {
        self.started = true
    }
        
    func stop() {
        self.started = false
    }
    
    func reset() {
        self.stop()
        self.start()
    }
    
    func frameCaptured(imageBuffer: CVPixelBuffer) {
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > captureOptions.timeBetweenImages {
            self.lastTimestamp = currentTimestamp
            
            DispatchQueue.main.async {
                if (!captureOptions.saveImageCaptured) {
                    return
                }
                
                let orientation = captureOptions.cameraLens.rawValue == 1 ?
                    UIImage.Orientation.up : UIImage.Orientation.upMirrored
                
                let image = imageFromPixelBuffer(
                    imageBuffer: imageBuffer,
                    scale: UIScreen.main.scale,
                    orientation: orientation)
                                        
                let fileURL = fileURLFor(index: self.numberOfImages)
                let filePath = try! save(
                    image: image,
                    fileURL: fileURL)
                
                self.handleEmitImageCaptured(filePath: filePath)
            }
        }
    }
    
    /**
     Handle emit frame image file created.
     
     - Parameter imagePath: image file path.
     */
    func handleEmitImageCaptured(filePath: String) {
        
        // process frame number of images.
        if (captureOptions.numberOfImages > 0) {
            if (self.numberOfImages < captureOptions.numberOfImages) {
                self.numberOfImages += 1
                self.cameraEventListener?.onImageCaptured(
                    "frame",
                    self.numberOfImages,
                    captureOptions.numberOfImages,
                    filePath
                )
                return
            }
            
            self.stop()
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        // process frame unlimited.
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onImageCaptured(
            "frame",
            self.numberOfImages,
            captureOptions.numberOfImages,
            filePath
        )
    }
}


