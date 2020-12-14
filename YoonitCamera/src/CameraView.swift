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


import Foundation
import AVFoundation
import UIKit

/**
 * Class responsible to handle the camera operations.
 */
@objc
public class CameraView: UIView {
    
    // Model to set CameraView features options.
    private var captureOptions: CaptureOptions = CaptureOptions()
    
    // Camera controller object.
    private var cameraController: CameraController? = nil
    
    // Manages multiple inputs and outputs of audio and video.
    private var session = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
    
    // Camera interface event listeners object.
    @objc
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.cameraController?.cameraEventListener = cameraEventListener
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.configure()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.previewLayer.frame = self.frame
    }
    
    private func configure() {
        
        self.layer.addSublayer(self.previewLayer)
        
        self.session.sessionPreset = .hd1280x720
        
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.frame
        
        self.cameraController = CameraController(
            cameraView: self,
            captureOptions: captureOptions,
            session: self.session,
            previewLayer: self.previewLayer)
    }
    
    /**
     Start camera preview if has permission.
     */
    @objc
    public func startPreview() {
        self.cameraController?.startPreview()
    }
    
    /**
     Start capture type: none, face, barcode or frame.
     Must have started preview, see `startPreview`.
     
     - Parameters: `"none"` | `"face"` | `"qrcode"` | `"frame"`.
     - Precondition: value string must be one of `"none"`, `"face"`, `"qrcode"`, `"frame"` and must have started preview.
     */
    @objc
    public func startCaptureType(captureType: String) {
        switch captureType {
        case "none":
            self.cameraController?.startCaptureType(captureType: CaptureType.NONE)
            
        case "face":
            self.cameraController?.startCaptureType(captureType: CaptureType.FACE)
            
        case "qrcode":
            self.cameraController?.startCaptureType(captureType: CaptureType.QRCODE)
            
        case "frame":
            self.cameraController?.startCaptureType(captureType: CaptureType.FRAME)
            
        default:
            fatalError(KeyError.INVALID_CAPTURE_TYPE.rawValue)
        }
    }
    
    /**
     Stop camera image capture.
     */
    @objc
    public func stopCapture() {
        self.cameraController?.stopAnalyzer()
    }
    
    /**
     Toggle between Front and Back Camera.
     */
    @objc
    public func toggleCameraLens() {
        self.cameraController!.toggleCameraLens()
    }
    
    /**
     Get current camera lens.
     
     - Returns: value 0 is front camera.
     Default value 1 is back camera.
     */
    @objc
    public func getCameraLens() -> Int {
        return self.cameraController!.getCameraLens()
    }
    
    /**
     Set number of face/frame file images to create.
     
     - Parameter numberOfImages: The number of images to create.
     Default value is 0.
     */
    @objc
    public func setNumberOfImages(numberOfImages: Int) {
        if numberOfImages < 0 {
            fatalError(KeyError.INVALID_NUMBER_OF_IMAGES.rawValue)
        }
        
        self.captureOptions.numberOfImages = numberOfImages
    }
    
    /**
     Set saving face/frame images time interval in milli seconds.
     
     - Parameter faceTimeBetweenImages: The time in milli seconds.
     Default value is `1000`.
     */
    @objc
    public func setTimeBetweenImages(timeBetweenImages: Int64) {
        if timeBetweenImages < 0 {
            fatalError(KeyError.INVALID_TIME_BETWEEN_IMAGES.rawValue)
        }
        
        self.captureOptions.timeBetweenImages = timeBetweenImages
    }
    
    /**
     Set face image width to be created.
     
     - Parameter width: The file image width in pixels.
     Default value is `200`.
     */
    @objc
    public func setOutputImageWidth(width: Int) {
        if (width <= 0) {
            fatalError(KeyError.INVALID_OUTPUT_IMAGE_WIDTH.rawValue)
        }
        
        self.captureOptions.imageOutputWidth = width
    }
    
    /**
     Set face image height to be created.
     
     - Parameter height: The file image height in pixels.
     Default value is `200`.
     */
    @objc
    public func setOutputImageHeight(height: Int) {
        if (height <= 0) {
            fatalError(KeyError.INVALID_OUTPUT_IMAGE_HEIGHT.rawValue)
        }
        
        self.captureOptions.imageOutputHeight = height
    }
    
    /**
     Set to enable/disable save images when capturing face/frame.
     
     - Parameter enable: The indicator to enable or disable the face/frame save images.
     Default value is `false`.
     */
    @objc
    public func setSaveImageCaptured(enable: Bool) {
        self.captureOptions.saveImageCaptured = enable
    }
    
    /**
     Set to show/hide face detection box when face detected.
     The detection box is the detected face bounding box draw.
     
     - Parameter enable: The indicator to show or hide the face detection box.
     Default value is `true`.
     */
    @objc
    public func setFaceDetectionBox(enable: Bool) {
        self.captureOptions.faceDetectionBox = enable
    }
    
    /**
     Enlarge the face bounding box by percent.
     
     - Parameter facePaddingPercent: The percent to enlarge the bounding box.
     Default value is `0.27`.
     */
    @objc
    public func setFacePaddingPercent(facePaddingPercent: Float) {
        if facePaddingPercent < 0 {
            fatalError(KeyError.INVALID_FACE_PADDING_PERCENT.rawValue)
        }
        
        self.captureOptions.facePaddingPercent = facePaddingPercent
    }
    
    /**
     Limit the minimum face capture size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.
     
     For example, if set 0.5, will capture face with the detection box width occupying
     at least 50% of the screen width.
     
     - Parameter faceCaptureMinSize The face capture min size value.
     Default value is `0`,
     */
    @objc
    public func setFaceCaptureMinSize(faceCaptureMinSize: Float) {
        if faceCaptureMinSize < 0.0 || faceCaptureMinSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_CAPTURE_MIN_SIZE.rawValue)
        }
        
        self.captureOptions.faceCaptureMinSize = faceCaptureMinSize
    }
    
    /**
     Limit the maximum face capture size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.
     
     For example, if set 0.7, will capture face with the detection box width occupying
     at least 70% of the screen width.
     
     - Parameter faceCaptureMaxSize The face capture max size value.
     Default value is `1.0`.
     */
    @objc
    public func setFaceCaptureMaxSize(faceCaptureMaxSize: Float) {
        if faceCaptureMaxSize < 0.0 || faceCaptureMaxSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_CAPTURE_MAX_SIZE.rawValue)
        }
        
        self.captureOptions.faceCaptureMaxSize = faceCaptureMaxSize
    }
    
    /**
     Set to apply enable/disable face region of interest.
     
     - Parameter enable: The indicator to enable/disable face region of interest.
     Default value is `false`.
     */
    @objc
    public func setFaceROIEnable(enable: Bool) {
        self.captureOptions.faceROI.enable = enable
    }
    
    /**
     Tried to input invalid face region of interest top offset.
     
     - Parameter percentage: The "above" area of the face bounding box in percentage.
     Default value is `0.0f`.
     */
    @objc
    public func setFaceROITopOffset(_ topOffset: Float) {
        if (topOffset < 0.0 || topOffset > 1.0) {
            fatalError(KeyError.INVALID_FACE_ROI_TOP_OFFSET.rawValue)
        }

        self.captureOptions.faceROI.topOffset = topOffset
    }

    /**
     Tried to input invalid face region of interest right offset.
     
     - Parameter percentage: The "right" area of the face bounding box in percentage.
     Default value is `0.0`.
     */
    @objc
    public func setFaceROIRightOffset(_ rightOffset: Float) {
        if (rightOffset < 0.0 || rightOffset > 1.0) {
            fatalError(KeyError.INVALID_FACE_ROI_RIGHT_OFFSET.rawValue)
        }

        self.captureOptions.faceROI.rightOffset = rightOffset
    }

    /**
     Tried to input invalid face region of interest bottom offset.
     
     - Parameter percentage: The "bottom" area of the face bounding box in percentage.
     Default value is `0.0`.
     */
    @objc
    public func setFaceROIBottomOffset(_ bottomOffset: Float) {
        if (bottomOffset < 0.0 || bottomOffset > 1.0) {
            fatalError(KeyError.INVALID_FACE_ROI_BOTTOM_OFFSET.rawValue)
        }

        self.captureOptions.faceROI.bottomOffset = bottomOffset
    }

    /**
     Tried to input invalid face region of interest left offset.
     
     - Parameter percentage: The "left" area of the face bounding box in percentage.
     Default value is `0.0`.
     */
    @objc
    public func setFaceROILeftOffset(_ leftOffset: Float) {
        if (leftOffset < 0.0 || leftOffset > 1.0) {
            fatalError(KeyError.INVALID_FACE_ROI_LEFT_OFFSET.rawValue)
        }

        self.captureOptions.faceROI.leftOffset = leftOffset
    }
    
    /**
     Set face minimum size in relation of the region of interest.
     
     - Parameter minimumSize: Represents in percentage [0, 1].
     Default value is `0`.
     */
    @objc
    public func setFaceROIMinSize(minimumSize: Float) {
        if minimumSize < 0.0 || minimumSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_ROI_MIN_SIZE.rawValue)
        }
        
        self.captureOptions.faceROI.minimumSize = minimumSize
    }
}

