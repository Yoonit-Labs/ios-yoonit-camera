//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya & Marcio Brufatto @ Cyberlabs AI 2020-2021       |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//

import AVFoundation
import UIKit
import YoonitFacefy

/**
 This class is responsible to handle the operations related with the face capture.
 */
class FaceAnalyzer {
    
    private let MAX_NUMBER_OF_IMAGES = 40
    
    private var cameraGraphicView: CameraGraphicView
    private var coordinatesController: CoordinatesController
    private let facefy: Facefy = Facefy()    
    private var cameraTimestamp = Date().currentTimeMillis()
    private var faceTimestamp = Date().currentTimeMillis()
    private var isValid = true
    
    public var numberOfImages = 0
    public var start: Bool = false {
        didSet {
            if !self.start {
                self.numberOfImages = 0
            }
            self.cameraGraphicView.draw = self.start
        }
    }
    public var cameraEventListener: CameraEventListenerDelegate?
        
    init(cameraGraphicView: CameraGraphicView) {
        self.cameraGraphicView = cameraGraphicView
        
        self.coordinatesController = CoordinatesController(
            cameraGraphicView: cameraGraphicView
        )
    }
        
    /**
     Try to detect faces in the moment the camera capture a frame.
     
     - Parameter imageBuffer: The camera frame captured.
     */
    func faceDetect(imageBuffer: CVPixelBuffer) {
        if !self.start {
            return
        }
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.cameraTimestamp
        
        if diffTime < 200 {
            return
        }
        self.cameraTimestamp = currentTimestamp
                                
        DispatchQueue.global(qos: .userInitiated).async {
            self.detect(imageBuffer: imageBuffer)
        }
    }
                    
    private func detect(imageBuffer: CVPixelBuffer) {
        
        guard let cameraInputImage: UIImage = imageBuffer
            .toUIImage()
            .flipHorizontally() else {
            return
        }
        
        self.facefy.detect(cameraInputImage) {
            faceDetected in
        
            // Get from faceDetected the graphic face bounding box.
            let detectionBox: CGRect = self
                .coordinatesController
                .getDetectionBox(
                    cameraInputImage: cameraInputImage,
                    faceDetected: faceDetected
                )
                        
            let error: String? = self
                .coordinatesController
                .hasFaceDetectionBoxError(detectionBox: detectionBox)
            
            // Handle emit error and face undetected.
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
                                                                                        
            // Process faceDetected results...
            if let faceDetected: FaceDetected = faceDetected {
                
                // Get the face contours scaled to UI graphic.
                let faceContours: [CGPoint] = self
                    .coordinatesController
                    .getFaceContours(
                        cameraInputImage: cameraInputImage,
                        contours: faceDetected.contours
                    )
                
                // Handle draw face detection box and face contours.
                self.cameraGraphicView.handleDraw(
                    detectionBox: detectionBox,
                    faceContours: faceContours
                )
                                                 
                let leftEyeOpenProbability = faceDetected.leftEyeOpenProbability != nil ? NSNumber(value: Float(faceDetected.leftEyeOpenProbability!)) : nil
                let rightEyeOpenProbability = faceDetected.rightEyeOpenProbability != nil ? NSNumber(value: Float(faceDetected.rightEyeOpenProbability!)) : nil
                let smilingProbability = faceDetected.smilingProbability != nil ? NSNumber(value: Float(faceDetected.smilingProbability!)) : nil
                let headEulerAngleX = faceDetected.headEulerAngleX != nil ? NSNumber(value: Float(faceDetected.headEulerAngleX!)) : nil
                let headEulerAngleY = faceDetected.headEulerAngleY != nil ? NSNumber(value: Float(faceDetected.headEulerAngleY!)) : nil
                let headEulerAngleZ = faceDetected.headEulerAngleZ != nil ? NSNumber(value: Float(faceDetected.headEulerAngleZ!)) : nil
                
                // Emit the faceDetected results.
                DispatchQueue.main.async {
                    self.cameraEventListener?.onFaceDetected(
                        Int(detectionBox.minX),
                        Int(detectionBox.minY),
                        Int(detectionBox.width),
                        Int(detectionBox.height),
                        leftEyeOpenProbability,
                        rightEyeOpenProbability,
                        smilingProbability,
                        headEulerAngleX,
                        headEulerAngleY,
                        headEulerAngleZ
                    )
                }
                                                                
                // Handle save the face detected image from the camera input image.
                let filePath: String? = self.handleSaveImage(
                    cameraInputImage: cameraInputImage,
                    faceDetected: faceDetected
                )
                
                if let filePath: String = filePath {
                    let (
                        darkness,
                        lightness,
                        sharpness
                    ) = ImageQualityController.processImage(imageBuffer: imageBuffer)
                    
                    self.handleEmitImageCaptured(
                        filePath: filePath,
                        darkness: darkness,
                        lightness: lightness,
                        sharpness: sharpness
                    )
                }
            }
        } onError: { message in
            self.cameraEventListener?.onError(message)
        }
    }
            
    /**
     Handle save the face detected image from the camera input image.
     
     - Parameter cameraInputImage: The camera frame captured.
     - Parameter faceDetected: The result of the face detected from the camera input image.
     
     - returns: the image file path.
     */
    private func handleSaveImage(
        cameraInputImage: UIImage,
        faceDetected: FaceDetected
    ) -> String? {
        
        if !captureOptions.saveImageCaptured {
            return nil
        }
        
        // Handle crop face process by time.
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.faceTimestamp
        
        if diffTime > captureOptions.timeBetweenImages {
            self.faceTimestamp = currentTimestamp
                                
            if let cgImage = cameraInputImage.cgImage {
                var croppedImage: UIImage = UIImage(
                    cgImage: cgImage.cropping(to: faceDetected.boundingBox)!
                )
                                
                if captureOptions.cameraLens == AVCaptureDevice.Position.back {
                    croppedImage = croppedImage.withHorizontallyFlippedOrientation()
                }
                
                let imageResized: UIImage = try! croppedImage.resize(
                    width: captureOptions.imageOutputWidth,
                    height: captureOptions.imageOutputHeight
                )
                                                
                let fileURL = fileURLFor(index: self.numberOfImages)
                let filePath = try! save(
                    image: imageResized,
                    fileURL: fileURL
                )
                
                return filePath
            }
        }
        
        return nil
    }
            
    /**
     Handle emit face file saved and the quality of the image;
     
     - Parameter filePath: image file path.
     - Parameter darkness: image darkness classification.
     - Parameter lightness: image lighness classification.
     - Parameter sharpness: image sharpness classification.
     */
    public func handleEmitImageCaptured(
        filePath: String,
        darkness: NSNumber?,
        lightness: NSNumber?,
        sharpness: NSNumber?
    ) {
        
        // process face number of images.
        if (captureOptions.numberOfImages > 0) {
            if (self.numberOfImages < captureOptions.numberOfImages) {
                self.numberOfImages += 1
                
                self.cameraEventListener?.onImageCaptured(
                    "face",
                    self.numberOfImages,
                    captureOptions.numberOfImages,
                    filePath,
                    darkness,
                    lightness,
                    sharpness
                )
                
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
            filePath,
            darkness,
            lightness,
            sharpness
        )
    }
}
