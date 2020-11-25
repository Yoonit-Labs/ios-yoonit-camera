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
    
    private var captureOptions: CaptureOptions
    private var cameraView: CameraView
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var faceCropController = FaceCropController()
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
        previewLayer: AVCaptureVideoPreviewLayer) {
        
        self.captureOptions = captureOptions
        self.cameraView = cameraView
        self.previewLayer = previewLayer
        
        self.faceBoundingBoxController = FaceBoundingBoxController(
            captureOptions: self.captureOptions,
            cameraView: self.cameraView,
            previewLayer: self.previewLayer)
    }
    
    /**
     Start face analyzer to capture frame.
     */
    func start() {
        self.shouldDraw = true
    }
    
    func stop() {
        self.drawings = []
        self.shouldDraw = false
    }
    
    func reset() {
        self.stop()
        self.start()
    }
    
    func faceDetect(imageBuffer: CVPixelBuffer) {
        
        let faceDetectRequest = VNDetectFaceRectanglesRequest {
            request, error in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(
                        faces: results,
                        imageBuffer: imageBuffer)
                } else {
                    if self.hasStatus {
                        self.hasStatus = false
                        self.cameraEventListener?.onFaceUndetected()
                        self.drawings = []
                    }
                }
            }
        }
         
        try? VNImageRequestHandler(
            cvPixelBuffer: imageBuffer,
            orientation: .leftMirrored,
            options: [:])
            .perform([faceDetectRequest])
    }
    
    private func handleFaceDetectionResults(
        faces: [VNFaceObservation],
        imageBuffer: CVPixelBuffer)
    {
        let orientation = captureOptions.cameraLens.rawValue == 1 ?
            UIImage.Orientation.up :
            UIImage.Orientation.upMirrored
                
        let image = imageFromPixelBuffer(
            imageBuffer: imageBuffer,
            scale: UIScreen.main.scale,
            orientation: orientation)
                .cgImage
        
        // The closest face.
        let closestFace: VNFaceObservation = self.faceBoundingBoxController.getClosestFace(faces)
                        
        // The detection box is the face bounding box coordinates normalized.
        let detectionBox = self.faceBoundingBoxController.getDetectionBox(
            boundingBox: closestFace.boundingBox,
            imageBuffer: imageBuffer)
        
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
        
        if !self.captureOptions.faceSaveImages {
            return
        }
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp            
        
        if diffTime > self.captureOptions.faceTimeBetweenImages {
            self.lastTimestamp = currentTimestamp
                                    
            self.faceCropController.cropImage(
                image: image!,
                boundingBox: closestFace.boundingBox,
                captureOptions: self.captureOptions) {
                result in
                
                let fileURL = fileURLFor(index: self.numberOfImages)
                let fileName = try! save(image: result, at: fileURL)
                
                self.notifyCapturedImage(filePath: fileName)
            }
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
