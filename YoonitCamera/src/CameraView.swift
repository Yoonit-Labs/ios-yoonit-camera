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

import Foundation
import AVFoundation
import UIKit
import Vision

// Singleton to set CameraView features options.
var captureOptions: CaptureOptions = CaptureOptions()

var previewLayer: AVCaptureVideoPreviewLayer!

/**
 * Class responsible to handle the camera operations.
 */
@objc
public class CameraView: UIView {
                
    // Camera controller object.
    private var cameraController: CameraController? = nil
    
    // Manages multiple inputs and outputs of audio and video.
    private var session = AVCaptureSession()
    private var cameraGraphicView: CameraGraphicView!
    
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
        
        previewLayer.frame = self.frame
        self.cameraGraphicView.frame = self.frame
    }
    
    private func configure() {
        self.session.sessionPreset = .hd1280x720
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.frame
        self.layer.addSublayer(previewLayer!)
                        
        self.cameraGraphicView = CameraGraphicView(frame: self.frame)
        self.addSubview(self.cameraGraphicView)
        
        self.cameraController = CameraController(
            session: self.session,
            cameraGraphicView: self.cameraGraphicView
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
     Set to enable/disable detection box when face/qrcode detected.
     The detection box is the the face/qrcode bounding box normalized to UI.
     
     - Parameter enable: The indicator to enable/disable detection box.
     Default value is `false`.
     */
    @objc
    public func setDetectionBox(_ enable: Bool) {
        captureOptions.detectionBox = enable
    }
    
    /**
     Set to enable/disable face contours when face detected.
     
     - Parameter enable: The indicator to enable/disable face contours.
     Default value is `false`.
     */
    @objc
    public func setFaceContours(_ enable: Bool) {
        captureOptions.faceContours = enable
    }

    /**
     Set face contours ARGB color.
     
     - Parameter alpha: The alpha value.
     - Parameter red: The red value.
     - Parameter green: The green value.
     - Parameter blue: The blue value.
     Default value is `(1.0, 1.0, 1.0, 1.0)`.
     */
    @objc
    public func setFaceContoursColor(
        alpha: Float,
        red: Float,
        green: Float,
        blue: Float
    ) {
        let isColorValid: Bool =
            alpha < 0.0 || alpha > 1.0 ||
            red < 0.0 || red > 1.0 ||
            green < 0.0 || green > 1.0 ||
            blue < 0.0 || blue > 1.0
        if isColorValid {
            fatalError(KeyError.INVALID_FACE_CONTOURS_COLOR.rawValue)
        }
        
        captureOptions.faceContoursColor = UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
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
     Set a face/qrcode minimum size to detect in percentage related with the camera preview.
     
     For example, if set `0.5`, will capture face/qrcode with the detection box width occupying
     at least 50% of the screen width.
     
     - Parameter minimumSize: Value between `0` and `1`.
     Default value is `0.0`,
     */
    @objc
    public func setMinimumSize(_ minimumSize: Float) {
        if minimumSize < 0.0 || minimumSize > 1.0 {
            fatalError(KeyError.INVALID_MINIMUM_SIZE.rawValue)
        }
        
        captureOptions.minimumSize = minimumSize
    }
    
    /**
     Set a face/qrcode maximum size to detect in percentage related with the camera preview.
     
     For example, if set `0.7`, will capture face/qrcode with the detection box width occupying
     until 70% of the screen width.
     
     - Parameter maximumSize: Value between `0` and `1`.
     Default value is `1.0`.
     */
    @objc
    public func setMaximumSize(_ maximumSize: Float) {
        if maximumSize < 0.0 || maximumSize > 1.0 {
            fatalError(KeyError.INVALID_MAXIMUM_SIZE.rawValue)
        }
        
        captureOptions.maximumSize = maximumSize
    }
    
    /**
     Set to apply enable/disable region of interest.
     
     - Parameter enable: The indicator to enable/disable region of interest.
     Default value is `false`.
     */
    @objc
    public func setROI(_ enable: Bool) {
        captureOptions.roi.enable = enable
    }
    
    /**
     Camera preview top distance in percentage.
     
     - Parameter percentage: Value between `0` and `1`. Represents the percentage.
     Default value is `0.0`.
     */
    @objc
    public func setROITopOffset(_ topOffset: Float) {
        if (topOffset < 0.0 || topOffset > 1.0) {
            fatalError(KeyError.INVALID_ROI_TOP_OFFSET.rawValue)
        }

        captureOptions.roi.topOffset = CGFloat(topOffset)
    }

    /**
     Camera preview right distance in percentage.
     
     - Parameter percentage: Value between `0` and `1`. Represents the percentage.
     Default value is `0.0`.
     */
    @objc
    public func setROIRightOffset(_ rightOffset: Float) {
        if (rightOffset < 0.0 || rightOffset > 1.0) {
            fatalError(KeyError.INVALID_ROI_RIGHT_OFFSET.rawValue)
        }

        captureOptions.roi.rightOffset = CGFloat(rightOffset)
    }

    /**
     Camera preview bottom distance in percentage.
     
     - Parameter percentage: Value between `0` and `1`. Represents the percentage.
     Default value is `0.0`.
     */
    @objc
    public func setROIBottomOffset(_ bottomOffset: Float) {
        if (bottomOffset < 0.0 || bottomOffset > 1.0) {
            fatalError(KeyError.INVALID_ROI_BOTTOM_OFFSET.rawValue)
        }

        captureOptions.roi.bottomOffset = CGFloat(bottomOffset)
    }

    /**
     Camera preview left distance in percentage.
     
     - Parameter percentage: Value between `0` and `1`. Represents the percentage.
     Default value is `0.0`.
     */
    @objc
    public func setROILeftOffset(_ leftOffset: Float) {
        if (leftOffset < 0.0 || leftOffset > 1.0) {
            fatalError(KeyError.INVALID_ROI_LEFT_OFFSET.rawValue)
        }

        captureOptions.roi.leftOffset = CGFloat(leftOffset)
    }
        
    /**
     Set to enable/disable region of interest offset visibility.
     
     - Parameter enable: The indicator to enable/disable region of interest visibility.
     Default value is `false`.
     */
    @objc
    public func setROIAreaOffset(_ enable: Bool) {
        captureOptions.roi.areaOffsetEnable = enable
    }

    /**
     Set region of interest area offset color.
     
     - Parameter alpha: Values between `0` and `1`.
     - Parameter red: Values between `0` and `1`.
     - Parameter green: Values between `0` and `1`.
     - Parameter blue: Values between `0` and `1`.
     Default value is `(0.4, 1.0, 1.0, 1.0)`.
     */
    @objc
    public func setROIAreaOffsetColor(
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
            fatalError(KeyError.INVALID_ROI_COLOR.rawValue)
        }
            
        captureOptions.roi.areaOffsetColor = UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }
}

