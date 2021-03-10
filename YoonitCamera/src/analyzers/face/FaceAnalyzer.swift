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
import YoonitFacefy

/**
 This class is responsible to handle the operations related with the face capture.
 */
class FaceAnalyzer: NSObject {
    
    private let MAX_NUMBER_OF_IMAGES = 25
    
    public var numberOfImages = 0
    public var start: Bool = false {
        didSet {
            if !self.start {
                self.numberOfImages = 0
                self.cameraGraphicView.clear()
            }
        }
    }
    public var cameraEventListener: CameraEventListenerDelegate?
    
    private var cameraGraphicView: CameraGraphicView
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var faceBoundingBoxController: FaceBoundingBoxController
    private let facefy: Facefy = Facefy()
    private var cameraTimestamp = Date().currentTimeMillis()
    private var lastTimestamp = Date().currentTimeMillis()
    private var isValid = true
        
    init(
        cameraGraphicView: CameraGraphicView,
        previewLayer: AVCaptureVideoPreviewLayer
    ) {
        self.cameraGraphicView = cameraGraphicView
        self.previewLayer = previewLayer
        
        self.faceBoundingBoxController = FaceBoundingBoxController(cameraGraphicView: cameraGraphicView)
    }
        
    /**
     Try to detect faces in the moment the camera capture a frame.
     
     - Parameter imageBuffer: The camera frame capture.
     */
    func faceDetect(imageBuffer: CVPixelBuffer) {
        
        // Handle crop face process by time.
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.cameraTimestamp
        
        if diffTime > 150 {
            self.cameraTimestamp = currentTimestamp
                            
            let image: UIImage = imageBuffer.toUIImage()
                            
            self.facefy.detect(image) { faceDetected in
                
                let detectionBox: CGRect? = self.faceBoundingBoxController.getDetectionBox(
                    cameraInputImage: image,
                    faceDetected: faceDetected
                )
                
                let error: String? = self
                    .faceBoundingBoxController
                    .hasFaceDetectedError(detectionBox: detectionBox)
                
                if error != nil {
                    if self.isValid {
                        self.isValid = false
                        self.cameraGraphicView.clear()
                        if error != "" {
                            self.cameraEventListener?.onMessage(error!)
                        }
                        self.cameraEventListener?.onFaceUndetected()
                    }
                    return
                }
                self.isValid = true
                
                guard let faceDetected: FaceDetected = faceDetected else {
                    return
                }
                                
                self.handleFaceDetected(
                    image: image ,
                    leftEyeOpenProbability: faceDetected.leftEyeOpenProbability,
                    rightEyeOpenProbability: faceDetected.rightEyeOpenProbability,
                    smilingProbability: faceDetected.smilingProbability,
                    headEulerAngleX: faceDetected.headEulerAngleX,
                    headEulerAngleY: faceDetected.headEulerAngleY,
                    headEulerAngleZ: faceDetected.headEulerAngleZ,
                    contours: faceDetected.contours,
                    boundingBox: faceDetected.boundingBox,
                    detectionBox: detectionBox!
                )
            } onError: { message in
                self.cameraEventListener?.onError(message)
            }
        }
    }
        
    private func handleFaceDetected(
        image: UIImage,
        leftEyeOpenProbability: CGFloat?,
        rightEyeOpenProbability: CGFloat?,
        smilingProbability: CGFloat?,
        headEulerAngleX: CGFloat?,
        headEulerAngleY: CGFloat?,
        headEulerAngleZ: CGFloat?,
        contours: [CGPoint],
        boundingBox: CGRect,
        detectionBox: CGRect
    ) {
        self.cameraGraphicView.handleDraw(boundingBox: detectionBox)
                    
        // Emit face detected detection box coordinates.
        self.cameraEventListener?.onFaceDetected(
            Int(boundingBox.minX),
            Int(boundingBox.minY),
            Int(boundingBox.width),
            Int(boundingBox.height)
        )
        
        if !captureOptions.saveImageCaptured {
            return
        }
        
        // Handle crop face process by time.
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.lastTimestamp
        
        if diffTime > captureOptions.timeBetweenImages {
            self.lastTimestamp = currentTimestamp
                                
            if let cgImage = image.cgImage {
                var croppedImage: UIImage = UIImage(
                    cgImage: cgImage.cropping(to: boundingBox)!
                )
                                
                if captureOptions.cameraLens == AVCaptureDevice.Position.front {
                    croppedImage = croppedImage.withHorizontallyFlippedOrientation()
                }
                
                let imageResized: UIImage = try! croppedImage.resize(
                    width: captureOptions.imageOutputWidth,
                    height: captureOptions.imageOutputHeight
                )
                                                
                let fileURL = fileURLFor(index: self.numberOfImages)
                let fileName = try! save(
                    image: imageResized,
                    fileURL: fileURL
                )
                
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
            
            self.numberOfImages = 0
            self.start = false
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
