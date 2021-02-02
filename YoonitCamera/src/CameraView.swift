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
import Vision

// Singleton to set CameraView features options.
var captureOptions: CaptureOptions = CaptureOptions()

/**
 * Class responsible to handle the camera operations.
 */
@objc
public class CameraView: UIView {
                
    // Camera controller object.
    private var cameraController: CameraController? = nil
    
    // Manages multiple inputs and outputs of audio and video.
    private var session = AVCaptureSession()
    private var cameraGraphicView: CameraGraphicView? = nil
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
        self.cameraGraphicView?.frame = self.frame
    }
    
    private func configure() {
        self.session.sessionPreset = .hd1280x720
        
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.frame
        self.layer.addSublayer(self.previewLayer)
                        
        self.cameraGraphicView = CameraGraphicView(frame: self.frame)
        self.addSubview(self.cameraGraphicView!)
        
        self.cameraController = CameraController(
            session: self.session,
            cameraGraphicView: self.cameraGraphicView!,
            previewLayer: self.previewLayer
        )
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
    public func startCaptureType(_ captureType: String) {
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
     Destroy camera preview.
     */
    @objc
    public func destroy() {
        captureOptions = CaptureOptions()
        self.cameraController?.destroy()
    }
        
    /**
     Toggle between Front and Back Camera.
     */
    @objc
    public func toggleCameraLens() {
        self.cameraController!.toggleCameraLens()
    }
    
    /**
     Set camera lens: "front" or "back".
     
     - Parameters: "back" || "front"
     */
    @objc
    public func setCameraLens(_ cameraLens: String) {
        if cameraLens != "front" && cameraLens != "back" {
            fatalError(KeyError.INVALID_CAMERA_LENS.rawValue)
        }

        let cameraSelector = cameraLens == "front"
            ? AVCaptureDevice.Position.front
            : AVCaptureDevice.Position.back

        if captureOptions.cameraLens != cameraSelector {
            self.cameraController!.toggleCameraLens()
        }
    }
    
    /**
     Get current camera lens.
     
     - Returns: "front" || "back".
     Default value is "front".
     */
    @objc
    public func getCameraLens() -> String {
        return captureOptions.cameraLens == AVCaptureDevice.Position.front
            ? "front"
            : "back"
    }
    
    /**
     Set number of face/frame file images to create.
     
     - Parameter numberOfImages: The number of images to create.
     Default value is 0.
     */
    @objc
    public func setNumberOfImages(_ numberOfImages: Int) {
        if numberOfImages < 0 {
            fatalError(KeyError.INVALID_NUMBER_OF_IMAGES.rawValue)
        }
        
        captureOptions.numberOfImages = numberOfImages
    }
    
    /**
     Set saving face/frame images time interval in milli seconds.
     
     - Parameter faceTimeBetweenImages: The time in milli seconds.
     Default value is `1000`.
     */
    @objc
    public func setTimeBetweenImages(_ timeBetweenImages: Int64) {
        if timeBetweenImages < 0 {
            fatalError(KeyError.INVALID_TIME_BETWEEN_IMAGES.rawValue)
        }
        
        captureOptions.timeBetweenImages = timeBetweenImages
    }
    
    /**
     Set face image width to be created.
     
     - Parameter width: The file image width in pixels.
     Default value is `200`.
     */
    @objc
    public func setOutputImageWidth(_ width: Int) {
        if (width <= 0) {
            fatalError(KeyError.INVALID_OUTPUT_IMAGE_WIDTH.rawValue)
        }
        
        captureOptions.imageOutputWidth = width
    }
    
    /**
     Set face image height to be created.
     
     - Parameter height: The file image height in pixels.
     Default value is `200`.
     */
    @objc
    public func setOutputImageHeight(_ height: Int) {
        if (height <= 0) {
            fatalError(KeyError.INVALID_OUTPUT_IMAGE_HEIGHT.rawValue)
        }
        
        captureOptions.imageOutputHeight = height
    }
    
    /**
     Set to enable/disable save images when capturing face/frame.
     
     - Parameter enable: The indicator to enable or disable the face/frame save images.
     Default value is `false`.
     */
    @objc
    public func setSaveImageCaptured(_ enable: Bool) {
        captureOptions.saveImageCaptured = enable
    }
    
    /**
     Set to show/hide face detection box when face detected.
     The detection box is the detected face bounding box draw.
     
     - Parameter enable: The indicator to show or hide the face detection box.
     Default value is `true`.
     */
    @objc
    public func setFaceDetectionBox(_ enable: Bool) {
        captureOptions.faceDetectionBox = enable
    }
    
    /**
     Enlarge the face bounding box by percent.
     
     - Parameter facePaddingPercent: The percent to enlarge the bounding box.
     Default value is `0.27`.
     */
    @objc
    public func setFacePaddingPercent(_ facePaddingPercent: Float) {
        if facePaddingPercent < 0 {
            fatalError(KeyError.INVALID_FACE_PADDING_PERCENT.rawValue)
        }
        
        captureOptions.facePaddingPercent = facePaddingPercent
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
    public func setFaceCaptureMinSize(_ faceCaptureMinSize: Float) {
        if faceCaptureMinSize < 0.0 || faceCaptureMinSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_CAPTURE_MIN_SIZE.rawValue)
        }
        
        captureOptions.faceCaptureMinSize = faceCaptureMinSize
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
    public func setFaceCaptureMaxSize(_ faceCaptureMaxSize: Float) {
        if faceCaptureMaxSize < 0.0 || faceCaptureMaxSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_CAPTURE_MAX_SIZE.rawValue)
        }
        
        captureOptions.faceCaptureMaxSize = faceCaptureMaxSize
    }
    
    /**
     Set to apply enable/disable face region of interest.
     
     - Parameter enable: The indicator to enable/disable face region of interest.
     Default value is `false`.
     */
    @objc
    public func setFaceROIEnable(_ enable: Bool) {
        captureOptions.faceROI.enable = enable
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

        captureOptions.faceROI.topOffset = CGFloat(topOffset)
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

        captureOptions.faceROI.rightOffset = CGFloat(rightOffset)
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

        captureOptions.faceROI.bottomOffset = CGFloat(bottomOffset)
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

        captureOptions.faceROI.leftOffset = CGFloat(leftOffset)
    }
    
    /**
     Set face minimum size in relation of the region of interest.
     
     - Parameter minimumSize: Represents in percentage [0, 1].
     Default value is `0`.
     */
    @objc
    public func setFaceROIMinSize(_ minimumSize: Float) {
        if minimumSize < 0.0 || minimumSize > 1.0 {
            fatalError(KeyError.INVALID_FACE_ROI_MIN_SIZE.rawValue)
        }
        
        captureOptions.faceROI.minimumSize = minimumSize
    }
    
    /**
     Set face region of interest offset color visibility.
     
     - Parameter enable: The indicator to show/hide the face region of interest area offset.
     Default value is `false`.
     */
    @objc
    public func setFaceROIAreaOffset(_ enable: Bool) {
        captureOptions.faceROI.areaOffsetEnable = enable
    }

    /**
     Set face region of interest area offset color.
     
     - Parameter red: Float that represent red color.
     - Parameter green: Float that represent green color.
     - Parameter blue: Float that represent blue color.
     - Parameter alpha: Float that represents the alpha.
     Default value is 0.4, 1.0, 1.0, 1.0 (white color).
     */
    @objc
    public func setFaceROIAreaOffsetColor(
        _ alpha: Float,
        _ red: Float,
        _ green: Float,
        _ blue: Float
    ) {
        if (
            alpha < 0.0 || alpha > 1.0 ||
            red < 0.0 || red > 1.0 ||
            green < 0.0 || green > 1.0 ||
            blue < 0.0 || blue > 1.0
        ) {
            fatalError(KeyError.INVALID_FACE_ROI_COLOR.rawValue)
        }
            
        captureOptions.faceROI.areaOffsetColor = UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }
}

