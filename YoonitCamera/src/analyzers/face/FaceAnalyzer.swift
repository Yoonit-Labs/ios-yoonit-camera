//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya & Marcio Brufatto @ Cyberlabs AI 2020            |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//


import AVFoundation
import UIKit
import Vision

/**
This class is responsible to handle the operations related with the face capture.
*/
class FaceAnalyzer: NSObject {
    
    private let MAX_NUMBER_OF_IMAGES = 25
    
    public var cameraEventListener: CameraEventListenerDelegate?
    private var session: AVCaptureSession!
    private var captureOptions: CaptureOptions
    private var cameraView: CameraView!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var faceQualityController = FaceQualityController()
    private var faceBoundingBoxController = FaceBoundinxBoxController()
    private var lastTimestamp = Date().currentTimeMillis()
    private var shouldDraw = true
    private var faceDetected = false
    public var numberOfImages = 0
    
    private let topSafeHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            return safeFrame.minY > 24 ? safeFrame.minY : 0
        } else {
            return 0
        }
    }()
    
    public var drawings: [CAShapeLayer] = [] {
        willSet {
            self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
        }
        didSet {
            if !self.drawings.isEmpty && self.shouldDraw {
                self.drawings.forEach({ shape in self.cameraView!.layer.addSublayer(shape) })
            }
        }
    }
    
    init(
        captureOptions: CaptureOptions,
        cameraView: CameraView,
        previewLayer: AVCaptureVideoPreviewLayer,
        session: AVCaptureSession
    ) {
        self.captureOptions = captureOptions
        self.cameraView = cameraView
        self.previewLayer = previewLayer
        self.session = session        
    }
    
    /**
     Start face analyzer to capture frame.
     */
    func start() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "face_analyzer_queue"))
        
        self.session?.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(
            with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
        
        self.shouldDraw = true
    }
    
    func stop() {
        self.session?.outputs.forEach({ self.session?.removeOutput($0) })
        self.drawings = []
        
        self.shouldDraw = false
    }
    
    func reset() {
        self.stop()
        self.start()
    }
    
    func faceDetect(image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: {
            (request: VNRequest, error: Error?) in
            
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(observedFaces: results, from: image)
                } else {
                    if self.faceDetected {
                        self.faceDetected = false
                        self.cameraEventListener?.onFaceUndetected()
                        self.drawings = []
                    }
                }
            }
        })
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: image,
            orientation: .leftMirrored,
            options: [:])
        
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(
        observedFaces: [VNFaceObservation],
        from pixelBuffer: CVPixelBuffer) {
        
        // The largest bounding box.
        let closestFace = observedFaces.sorted {
            return $0.boundingBox.width > $1.boundingBox.width
            }[0]
        
        let scale = self.pixelsToDotsRatio(pixelBuffer)
        
        // From normalized coordinates to screen (dots) coordinates.
        let faceBoundingBox = self.previewLayer!.layerRectConverted(fromMetadataOutputRect: closestFace.boundingBox)
        let faceBoundingBoxExtended = faceBoundingBox.increase(by: CGFloat(self.captureOptions.facePaddingPercent))
        let faceBoundingBoxScaled = faceBoundingBoxExtended.adjustedBySafeArea(height: topSafeHeight/scale)
        
        let left = Int(faceBoundingBoxScaled.minX)
        let top = Int(faceBoundingBoxScaled.minY)
        let right = Int(faceBoundingBoxScaled.maxX)
        let bottom = Int(faceBoundingBoxScaled.maxY)
        
        if
            left < 0 ||
                top < 0 ||
                bottom > Int(UIScreen.main.bounds.height) ||
                right > Int(UIScreen.main.bounds.width) {
            if self.faceDetected {
                self.faceDetected = false
                self.cameraEventListener?.onFaceUndetected()
                self.drawings = []
            }
            return
        }
        self.faceDetected = true
        
        // Draw face bounding box.
        if captureOptions.faceDetectionBox {
            self.drawings = self.faceBoundingBoxController.makeShapeFor(boundingBox: faceBoundingBoxScaled)
        } else {
            self.drawings = []
        }
        
        self.cameraEventListener?.onFaceDetected(
            x: left,
            y: top,
            width: right,
            height: bottom)
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > self.captureOptions.faceTimeBetweenImages {
            self.lastTimestamp = currentTimestamp
            self.faceQualityController.process(
                pixels: pixelBuffer,
                toRect: faceBoundingBoxExtended,
                atScale: scale,
                captureOptions: self.captureOptions,
                faceAnalyzer: self)
        }
    }
    
    public func notifyCapturedImage(filePath: String) {
        if (self.captureOptions.faceNumberOfImages > 0) {
            if (self.numberOfImages < self.captureOptions.faceNumberOfImages) {
                self.numberOfImages += 1
                self.cameraEventListener?.onFaceImageCreated(
                    count: numberOfImages,
                    total: self.captureOptions.faceNumberOfImages,
                    imagePath: filePath
                )
                return
            }
            
            self.stop()
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        self.numberOfImages = (numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onFaceImageCreated(
            count: numberOfImages,
            total: self.captureOptions.faceNumberOfImages,
            imagePath: filePath
        )
    }
    
    private func pixelsToDotsRatio(_ pixelBuffer: CVPixelBuffer) -> CGFloat {
        return CGFloat(CVPixelBufferGetWidth(pixelBuffer))/self.cameraView!.bounds.width
    }
}

extension FaceAnalyzer: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        if (!self.shouldDraw) {
            return
        }
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.cameraEventListener?.onError(error: "Unable to get image from sample buffer.")
            debugPrint("Unable to get image from sample buffer.")
            return
        }
        
        self.faceDetect(image: frame)
    }
}

