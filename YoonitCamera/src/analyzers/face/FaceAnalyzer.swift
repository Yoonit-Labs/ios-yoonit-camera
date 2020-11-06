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
    
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.faceBoundingBoxController.cameraEventListener = cameraEventListener
        }
    }
    
    private var session: AVCaptureSession!
    private var captureOptions: CaptureOptions
    private var cameraView: CameraView
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var faceQualityController = FaceQualityController()
    private var faceBoundingBoxController: FaceBoundingBoxController
    private var lastTimestamp = Date().currentTimeMillis()
    private var shouldDraw = true
    private var hasStatus = false
    public var numberOfImages = 0
    
    public var drawings: [CAShapeLayer] = [] {
        willSet {
            self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
        }
        didSet {
            if !self.drawings.isEmpty && self.shouldDraw {
                self.drawings.forEach({ shape in self.cameraView.layer.addSublayer(shape) })
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
        
        self.faceBoundingBoxController = FaceBoundingBoxController(
            captureOptions: self.captureOptions,
            cameraView: self.cameraView,
            previewLayer: self.previewLayer)
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
                    self.handleFaceDetectionResults(faces: results, from: image)
                } else {
                    if self.hasStatus {
                        self.hasStatus = false
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
        faces: [VNFaceObservation],
        from pixelBuffer: CVPixelBuffer) {
        
        // The closest face bounding box.
        let closestFaceBoundingBox = self.faceBoundingBoxController.getClosestFaceBoundingBox(faces)
        
        // The detection box is the face bounding box coordinates normalized.
        let detectionBox = self.faceBoundingBoxController.getDetectionBox(
            boundingBox: closestFaceBoundingBox,
            pixelBuffer: pixelBuffer)
        
        // Get status if exist.
        let status = self.getStatus(detectionBox: detectionBox)
        
        // Emit once if has error.
        if status != nil {
            if self.hasStatus {
                self.hasStatus = false
                self.drawings = []
                if (status != "") {
                    self.cameraEventListener?.onMessage(message: status!)
                }
                self.cameraEventListener?.onFaceUndetected()
            }
            return
        }
        self.hasStatus = true
        
        // Draw face bounding box.
        if self.captureOptions.faceDetectionBox {
            self.drawings = self.faceBoundingBoxController.makeShapeFor(boundingBox: detectionBox!)
        } else {
            self.drawings = []
        }
        
        self.cameraEventListener?.onFaceDetected(
            x: Int(detectionBox!.minX),
            y: Int(detectionBox!.minY),
            width: Int(detectionBox!.width),
            height: Int(detectionBox!.height))
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > self.captureOptions.faceTimeBetweenImages {
            self.lastTimestamp = currentTimestamp
            self.faceQualityController.process(
                pixels: pixelBuffer,
                toRect: closestFaceBoundingBox,
                captureOptions: self.captureOptions,
                faceAnalyzer: self)
        }
    }
    
    private func getStatus(detectionBox: CGRect?) -> String? {
        if detectionBox == nil {
            return ""
        }
        
        if
            detectionBox!.minX < 0 ||
                detectionBox!.minY < 0 ||
                detectionBox!.maxY > UIScreen.main.bounds.height ||
                detectionBox!.maxX > UIScreen.main.bounds.width {
            return ""
        }
                                                           
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let detectionBoxRelatedWithScreen = Float(detectionBox!.width) / Float(self.previewLayer.bounds.width)

        if (detectionBoxRelatedWithScreen < self.captureOptions.faceCaptureMinSize) {
            return Message.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue
        }
        
        if (detectionBoxRelatedWithScreen > self.captureOptions.faceCaptureMaxSize) {
            return Message.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue
        }
        
        return nil
    }
    
    public func notifyCapturedImage(filePath: String) {
        if (self.captureOptions.faceNumberOfImages > 0) {
            if (self.numberOfImages < self.captureOptions.faceNumberOfImages) {
                self.numberOfImages += 1
                self.cameraEventListener?.onFaceImageCreated(
                    count: self.numberOfImages,
                    total: self.captureOptions.faceNumberOfImages,
                    imagePath: filePath
                )
                return
            }
            
            self.stop()
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onFaceImageCreated(
            count: self.numberOfImages,
            total: self.captureOptions.faceNumberOfImages,
            imagePath: filePath
        )
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
