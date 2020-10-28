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
    private var session: AVCaptureSession!
    private var captureOptions: CaptureOptions
        
    private var lastTimestamp = Date().currentTimeMillis()
    private var started = false
    public var numberOfImages = 0
        
    init(captureOptions: CaptureOptions, session: AVCaptureSession) {
        self.captureOptions = captureOptions
        self.session = session
    }
    
    /**
     Start frame analyzer to capture frame.
     */
    func start() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "frame_analyzer_queue"))
        
        self.session?.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(
            with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
        
        self.started = true
    }
        
    func stop() {
        self.session?.outputs.forEach({ self.session?.removeOutput($0) })
        self.started = false
    }
    
    func reset() {
        self.stop()
        self.start()
    }
    
    func frameCaptured(imageBuffer: CVPixelBuffer) {
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > self.captureOptions.frameTimeBetweenImages {
            self.lastTimestamp = currentTimestamp
            
            DispatchQueue.main.async {
                self.handleEmitFrameCaptured(imageBuffer: imageBuffer)
            }
        }
    }
    
    func handleEmitFrameCaptured(imageBuffer: CVPixelBuffer) {
        let orientation = captureOptions.cameraLens.rawValue == 1 ? UIImage.Orientation.up : UIImage.Orientation.upMirrored
        let image = imageFromPixelBuffer(
            imageBuffer: imageBuffer,
            scale: UIScreen.main.scale,
            orientation: orientation)
        let fileURL = fileURLFor(index: self.numberOfImages)
        let filePath = try! save(image: image, at: fileURL)
        
        if (self.captureOptions.frameNumberOfImages > 0) {
            if (self.numberOfImages < self.captureOptions.frameNumberOfImages) {
                self.numberOfImages += 1
                self.cameraEventListener?.onFrameImageCreated(
                    count: self.numberOfImages,
                    total: self.captureOptions.frameNumberOfImages,
                    imagePath: filePath
                )
                return
            }
            
            self.stop()
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onFrameImageCreated(
            count: self.numberOfImages,
            total: self.captureOptions.frameNumberOfImages,
            imagePath: filePath
        )
    }
}

extension FrameAnalyzer: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        if (!self.started) {
            return
        }
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.cameraEventListener?.onError(error: "Unable to get image from sample buffer.")
            debugPrint("Unable to get image from sample buffer.")
            return
        }
                       
        self.frameCaptured(imageBuffer: frame)
    }
}


