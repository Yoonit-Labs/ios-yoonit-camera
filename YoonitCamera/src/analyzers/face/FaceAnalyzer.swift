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
        
    private var cameraView: CameraView
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var faceCropController = FaceCropController()
    private var faceBoundingBoxController: FaceBoundingBoxController
    private var lastTimestamp = Date().currentTimeMillis()
    private var shouldDraw = true
    private var isValid = true
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
        cameraView: CameraView,
        previewLayer: AVCaptureVideoPreviewLayer) {
        
        self.cameraView = cameraView
        self.previewLayer = previewLayer
        
        self.faceBoundingBoxController = FaceBoundingBoxController(
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
            options: [:]
        ).perform([faceDetectRequest])
    }
    
    /**
     Handle face detection result from Vision API.
     
     - Parameter faces: The array of face detected.
     - Parameter imageBuffer: The image buffer in the moment that detected the faces.
     */
    private func handleFaceDetectionResults(
        faces: [VNFaceObservation],
        imageBuffer: CVPixelBuffer
    ) {
        // Convert image orientation based on device lens.
        let orientation = captureOptions.cameraLens == AVCaptureDevice.Position.back ?
            UIImage.Orientation.up :
            UIImage.Orientation.upMirrored
                
        // Convert CVPixelBuffer to CGImage.
        let image: CGImage? = imageFromPixelBuffer(
            imageBuffer: imageBuffer,
            scale: UIScreen.main.scale,
            orientation: orientation
        ).cgImage
        
        // The closest face.
        let closestFace: VNFaceObservation = faces.sorted {
            return $0.boundingBox.width > $1.boundingBox.width
            }[0]
                        
        // The detection box is the face bounding box coordinates normalized.
        let detectionBox = self.faceBoundingBoxController.getDetectionBox(
            boundingBox: closestFace.boundingBox,
            imageBuffer: imageBuffer
        )
        
        // Validate detection box.
        // - nil for no error found;
        // - String for error found with message;
        // - "" for error found without message;
        let error: String? = self
            .faceBoundingBoxController
            .getError(detectionBox: detectionBox)
        
        // Emit once if has error.
        if error != nil {
            if self.isValid {
                self.isValid = false
                self.drawings = []
                if error != "" {
                    self.cameraEventListener?.onMessage(error!)
                }
                self.cameraEventListener?.onFaceUndetected()
            }
            return
        }
        self.isValid = true
        
        // Draw face detection box or clean.
        self.drawings = captureOptions.faceDetectionBox ?
            self.faceBoundingBoxController.makeShapeFor(boundingBox: detectionBox!) : []
        
        // Emit face detected detection box coordinates.
        self.cameraEventListener?.onFaceDetected(
            Int(detectionBox!.minX),
            Int(detectionBox!.minY),
            Int(detectionBox!.width),
            Int(detectionBox!.height)
        )
        
        if !captureOptions.saveImageCaptured {
            return
        }
        
        // Handle crop face process by time.
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > captureOptions.timeBetweenImages {
            self.lastTimestamp = currentTimestamp
        
            // Crop the face image.
            self.faceCropController.cropImage(
                image: image!,
                boundingBox: closestFace.boundingBox,
                captureOptions: captureOptions) {
                
                // Result of the crop face process.
                result in
                
                let imageResized = try! result.resize(
                    width: captureOptions.imageOutputWidth,
                    height: captureOptions.imageOutputHeight)
                
                let fileURL = fileURLFor(index: self.numberOfImages)
                let fileName = try! save(
                    image: imageResized,
                    fileURL: fileURL)
                                
                // Emit the face image file path.
                self.handleEmitImageCaptured(filePath: fileName)
            }
        }
    }
        
    /**
     Handle emit face image file created.
     
     - Parameter imagePath: image file path.
     */
    public func handleEmitImageCaptured(filePath: String) {
        
        // process face number of images.
        if (captureOptions.numberOfImages > 0) {
            if (self.numberOfImages < captureOptions.numberOfImages) {
                self.numberOfImages += 1
                
                self.cameraEventListener?.onImageCaptured(
                    "face",
                    self.numberOfImages,
                    captureOptions.numberOfImages,
                    filePath)
                
                return
            }
            
            self.stop()
            self.cameraEventListener?.onEndCapture()
            return
        }
        
        // process face unlimited.
        self.numberOfImages = (self.numberOfImages + 1) % MAX_NUMBER_OF_IMAGES
        self.cameraEventListener?.onImageCaptured(
            "face",
            self.numberOfImages,
            captureOptions.numberOfImages,
            filePath
        )
    }
}
