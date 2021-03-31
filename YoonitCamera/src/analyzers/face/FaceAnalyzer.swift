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
import Vision

/**
 This class is responsible to handle the operations related with the face capture.
 */
class FaceAnalyzer {
    
    private let MAX_NUMBER_OF_IMAGES = 40
    
    private var cameraGraphicView: CameraGraphicView
    private var coordinatesController: CoordinatesController
    private let facefy: Facefy = Facefy()
    private var faceCropController = FaceCropController()
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
        
        if diffTime > 200 {
            self.cameraTimestamp = currentTimestamp
            
            self.faceDetectWithVision(imageBuffer: imageBuffer)
        }
    }
    
    private func faceDetectWithVision(imageBuffer: CVPixelBuffer) {
        
        // Detection face using VIsion API.
        let faceDetectRequest = VNDetectFaceRectanglesRequest {
            request, error in
            
            if error != nil && !self.start {
                return
            }
            
            DispatchQueue.main.async {
                // Found faces...
                if let faces = request.results as? [VNFaceObservation], faces.count > 0 {
                    
                    // Get image orientation.
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
                    let detectionBox: CGRect = self.coordinatesController.getDetectionBox(
                        boundingBox: closestFace.boundingBox,
                        imageBuffer: imageBuffer
                    )
                    
                    // Validate detection box.
                    // - nil for no error found;
                    // - String for error found with message;
                    // - "" for error found without message;
                    let error: String? = self
                        .coordinatesController
                        .hasFaceDetectionBoxError(detectionBox: detectionBox)
                    
                    // Emit once if has error.
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
                    
                    // Draw face detection box or clean.
                    self.cameraGraphicView.handleDraw(
                        detectionBox: detectionBox,
                        faceContours: []
                    )
                    
                    let cameraInputImage: UIImage = imageBuffer.toUIImage()
                    self.facefy.detect(cameraInputImage) { faceDetected in
                        if let faceDetected: FaceDetected = faceDetected {
                            let leftEyeOpenProbability = faceDetected.leftEyeOpenProbability != nil ? NSNumber(value: Float(faceDetected.leftEyeOpenProbability!)) : nil
                            let rightEyeOpenProbability = faceDetected.rightEyeOpenProbability != nil ? NSNumber(value: Float(faceDetected.rightEyeOpenProbability!)) : nil
                            let smilingProbability = faceDetected.smilingProbability != nil ? NSNumber(value: Float(faceDetected.smilingProbability!)) : nil
                            let headEulerAngleX = faceDetected.headEulerAngleX != nil ? NSNumber(value: Float(faceDetected.headEulerAngleX!)) : nil
                            let headEulerAngleY = faceDetected.headEulerAngleY != nil ? NSNumber(value: Float(faceDetected.headEulerAngleY!)) : nil
                            let headEulerAngleZ = faceDetected.headEulerAngleZ != nil ? NSNumber(value: Float(faceDetected.headEulerAngleZ!)) : nil
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
                    } onError: { message in }
                    
                    if !captureOptions.saveImageCaptured {
                        return
                    }
                    
                    // Handle crop face process by time.
                    let currentTimestamp = Date().currentTimeMillis()
                    let diffTime = currentTimestamp - self.faceTimestamp
                    
                    if diffTime > captureOptions.timeBetweenImages {
                        self.faceTimestamp = currentTimestamp
                    
                        // Crop the face image.
                        self.faceCropController.cropImage(
                            image: image!,
                            boundingBox: closestFace.boundingBox,
                            captureOptions: captureOptions
                        ) { result in
                            
                            let imageResized = try! result.resize(
                                width: captureOptions.imageOutputWidth,
                                height: captureOptions.imageOutputHeight
                            )
                            
                            let fileURL = fileURLFor(index: self.numberOfImages)
                            let fileName = try! save(
                                image: imageResized,
                                fileURL: fileURL)
                                            
                            // Emit the face image file path.
                            self.handleEmitImageCaptured(filePath: fileName)
                        }
                    }
                } else if self.isValid {
                    self.isValid = false
                    self.cameraGraphicView.clear()
                    self.cameraEventListener?.onFaceUndetected()
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
    
    private func faceDetectWithFacefy(imageBuffer: CVPixelBuffer) {
                                                
        let cameraInputImage: UIImage = imageBuffer.toUIImage()
                        
        self.facefy.detect(cameraInputImage) { faceDetected in
            
            // Get from faceDetected the graphic face bounding box.
            let detectionBox: CGRect = self.coordinatesController
                .getDetectionBox(
                    cameraInputImage: cameraInputImage,
                    faceDetected: faceDetected
                )
            
            // Verify if has error on detection box.
            if self.hasError(
                cameraInputImage: cameraInputImage,
                detectionBox: detectionBox
            ) {
                return
            }
                                        
            // Process faceDetected results...
            if let faceDetected: FaceDetected = faceDetected {
                
                // Get the face contours scaled to UI graphic.
                let faceContours: [CGPoint] = self.coordinatesController.getFaceContours(
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
                
                // Handle save the face detected image from the camera input image.
                self.handleSaveImage(
                    cameraInputImage: cameraInputImage,
                    faceDetected: faceDetected
                )
            }
        } onError: { message in
            self.cameraEventListener?.onError(message)
        }
    }
    
    /**
     Verify if has error on detection box.
     
     - Parameter cameraInputImage: The camera frame captured.
     - Parameter detectionBox: The face detection box graphic UI.
     */
    private func hasError(
        cameraInputImage: UIImage,
        detectionBox: CGRect
    ) -> Bool {
        // Get error, if exists, from the face detection box.
        let error: String? = self.coordinatesController
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
            return true
        }
        self.isValid = true
        
        return false
    }
        
    /**
     Handle save the face detected image from the camera input image.
     
     - Parameter cameraInputImage: The camera frame captured.
     - Parameter faceDetected: The result of the face detected from the camera input image.
     */
    private func handleSaveImage(
        cameraInputImage: UIImage,
        faceDetected: FaceDetected
    ) {
        if !captureOptions.saveImageCaptured {
            return
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
     
     - Parameter filePath: image file path.
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
