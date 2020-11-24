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
    private var isValid = false
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
    
    /**
     Try to detect faces in the moment the camera capture this frame.
     
     - Parameter imageBuffer: The camera frame capture.
     */
    func faceDetect(imageBuffer: CVPixelBuffer) {
        
        // Detection face using VIsion API.
        let faceDetectRequest = VNDetectFaceRectanglesRequest {
            request, error in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                // Found faces...
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(
                        faces: results,
                        imageBuffer: imageBuffer)
                } else if self.isValid {
                    self.isValid = false
                    self.cameraEventListener?.onFaceUndetected()
                    self.drawings = []
                }
            }
        }
         
        // Start process detect face in the current image camera captured.
        try? VNImageRequestHandler(
            cvPixelBuffer: imageBuffer,
            orientation: .leftMirrored,
            options: [:])
            .perform([faceDetectRequest])
    }
    
    /**
     Handle face detection result from Vision API.
     
     - Parameter faces: The array of face detected.
     - Parameter imageBuffer: The image buffer in the moment that detected the faces.
     */
    private func handleFaceDetectionResults(
        faces: [VNFaceObservation],
        imageBuffer: CVPixelBuffer) {
        
        // Convert image orientation based on device lens.
        let orientation = captureOptions.cameraLens == AVCaptureDevice.Position.back ?
            UIImage.Orientation.up :
            UIImage.Orientation.upMirrored
                
        // Convert CVPixelBuffer to CGImage.
        let image: CGImage? = imageFromPixelBuffer(
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
        
        // Validate detection box.
        self.isValid = self.validate(detectionBox: detectionBox)
        
        // Emit once if has error.
        if !self.isValid {
            self.isValid = false
            self.drawings = []
            self.cameraEventListener?.onFaceUndetected()
            return
        }
        self.isValid = true
        
        // Draw face bounding box.
        if self.captureOptions.faceDetectionBox {
            self.drawings = self.faceBoundingBoxController.makeShapeFor(boundingBox: detectionBox!)
        } else {
            self.drawings = []
        }
        
        // Emit face detected detection box coordinates.
        self.cameraEventListener?.onFaceDetected(
            x: Int(detectionBox!.minX),
            y: Int(detectionBox!.minY),
            width: Int(detectionBox!.width),
            height: Int(detectionBox!.height))
        
        if !self.captureOptions.faceSaveImages {
            return
        }
        
        // Handle crop face process by time.
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > self.captureOptions.faceTimeBetweenImages {
            self.lastTimestamp = currentTimestamp
        
            // Crop the face image.
            self.faceCropController.cropImage(
                image: image!,
                boundingBox: closestFace.boundingBox,
                captureOptions: self.captureOptions) {
                
                // Result of the crop face process.
                result in
                
                let fileURL = fileURLFor(index: self.numberOfImages)
                let fileName = try! save(image: result, at: fileURL)
                
                
                // Emit the face image file path.
                self.handleEmitImageCaptured(filePath: fileName)
            }
        }
    }
    
    /**
     Validade the face detection box coordinates based in the capture options rules.
     
     - Parameter detectionBox: the face detection box coordinates.
     */
    private func validate(detectionBox: CGRect?) -> Bool {
        
        if detectionBox == nil {
            return false
        }
        
        let screenWidth = self.previewLayer.bounds.width
        let screenHeight = self.previewLayer.bounds.height
        
        let topOffset = Float(detectionBox!.minY / screenHeight)
        let rightOffset = Float((screenWidth - detectionBox!.maxX) / screenWidth)
        let bottomOffset = Float((screenHeight - detectionBox!.maxY) / screenHeight)
        let leftOffset = Float(detectionBox!.minX / screenWidth)
                   
        // Face is out of the screen.
        let isOutOfTheScreen =
            detectionBox!.minX < 0 ||
            detectionBox!.minY < 0 ||
            detectionBox!.maxY > screenHeight ||
            detectionBox!.maxX > screenWidth
        if isOutOfTheScreen {
            return false
        }
        
        // Face is out of the region of interest.
        let isOutOfTheROI =
            self.captureOptions.faceROI.topOffset > topOffset ||
            self.captureOptions.faceROI.rightOffset > rightOffset ||
            self.captureOptions.faceROI.bottomOffset > bottomOffset ||
            self.captureOptions.faceROI.leftOffset > leftOffset
        if isOutOfTheROI && self.captureOptions.faceROI.enable {
            return false
        }
                                                           
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let detectionBoxRelatedWithScreen = Float(detectionBox!.width / screenWidth)

        // Face smaller than the capture minimum size.
        if (detectionBoxRelatedWithScreen < self.captureOptions.faceCaptureMinSize) {
            return false
        }
        
        // Face bigger than the capture maximum size.
        if (detectionBoxRelatedWithScreen > self.captureOptions.faceCaptureMaxSize) {
            return false
        }
        
        return true
    }
    
    /**
     Handle emit face image file created.
     
     - Parameter imagePath: image file path.
     */
    public func handleEmitImageCaptured(filePath: String) {
        
        // process face number of images.
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
        
        // process face unlimited.
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onFaceImageCreated(
            count: self.numberOfImages,
            total: self.captureOptions.faceNumberOfImages,
            imagePath: filePath
        )
    }
}
