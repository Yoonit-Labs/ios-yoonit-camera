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
    private var cameraController: CameraControllerProtocol?
    
    // Camera interface event listeners object.
    @objc
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.cameraController?.cameraEventListener = cameraEventListener
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.cameraController = CameraController(cameraView: self, captureOptions: captureOptions)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.cameraController = CameraController(cameraView: self, captureOptions: captureOptions)
    }
    
    /**
     UIView update layout and subviews.
     Used to update camera controller subviews.
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.cameraController != nil) {
            self.cameraController?.layoutSubviews()
        }
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
     
     - Parameters: `"none"` | `"face"` | `"barcode"` | `"frame"`;
     - Precondition: value string must be one of `"none"`, `"face"`, `"barcode"`, `"frame"` and must have started preview.;
     */
    @objc
    public func startCaptureType(captureType: String) {
        switch captureType {
        case "none":
            self.cameraController?.startCaptureType(captureType: CaptureType.NONE)
            
        case "face":
            self.cameraController?.startCaptureType(captureType: CaptureType.FACE)
            
        case "barcode":
            self.cameraController?.startCaptureType(captureType: CaptureType.BARCODE)
            
        case "frame":
            self.cameraController?.startCaptureType(captureType: CaptureType.FRAME)
            
        default:
            if (self.cameraEventListener != nil) {
                self.cameraEventListener?.onError(error: KeyError.INVALID_CAPTURE_TYPE.rawValue)
            }
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
     
     - Returns: value 0 is front camera; value 1 is back camera.
     */
    @objc
    public func getCameraLens() -> Int {
        return (self.cameraController?.getCameraLens())!
    }
    
    /**
     Set number of face file images to create;
     The time interval to create the image is 1000 milli second.
     See setFaceTimeBetweenImages to change the time interval.
     
     - Parameter faceNumberOfImages: The number of images to create;
     */
    @objc
    public func setFaceNumberOfImages(faceNumberOfImages: Int) {
        self.captureOptions.faceNumberOfImages = faceNumberOfImages
    }
    
    /**
     Set to show/hide face detection box when face detected.
     The detection box is the detected face bounding box draw.
     
     - Parameter faceDetectionBox: The indicator to show or hide the face detection box. Default value is `true`;
     */
    @objc
    public func setFaceDetectionBox(faceDetectionBox: Bool) {
        self.captureOptions.faceDetectionBox = faceDetectionBox
    }
    
    /**
     Set saving face images time interval in milli seconds.
     
     - Parameter faceTimeBetweenImages: The time in milli seconds. Default value is `1000`;
     */
    @objc
    public func setFaceTimeBetweenImages(faceTimeBetweenImages: Int64) {
        self.captureOptions.faceTimeBetweenImages = faceTimeBetweenImages
    }
    
    /**
     Enlarge the face bounding box by percent.
     
     - Parameter facePaddingPercent: The percent to enlarge the bounding box. Default value is `0.27`;
     */
    @objc
    public func setFacePaddingPercent(facePaddingPercent: Float) {
        self.captureOptions.facePaddingPercent = facePaddingPercent
    }
    
    /**
     Set face image width and height to be saved.
     
     - Parameter width: The face image width saved in pixel. Default value is `200`;
     - Parameter height: The face image height saved in pixel. Default value is `200`;
     - Precondition: `width` and `height` must be greater than 0;
     */
    @objc
    public func setFaceImageSize(width: Int, height: Int) {
        self.captureOptions.faceImageSize = CGSize(width: width, height: height)
    }
    
    /**
     Limit the minimum face capture size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.
     
     For example, if set 0.5, will capture face with the detection box width occupying
     at least 50% of the screen width.
     
     - Parameter faceCaptureMinSize The face capture min size value. Default value is 0;
     */
    @objc
    public func setFaceCaptureMinSize(faceCaptureMinSize: Float) {
        self.captureOptions.faceCaptureMinSize = faceCaptureMinSize
    }
    
    /**
     Limit the maximum face capture size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.
     
     For example, if set 0.7, will capture face with the detection box width occupying
     at least 70% of the screen width.
     
     - Parameter faceCaptureMaxSize The face capture max size value. Default value is 1.0;
     */
    @objc
    public func setFaceCaptureMaxSize(faceCaptureMaxSize: Float) {
        self.captureOptions.faceCaptureMaxSize = faceCaptureMaxSize
    }
    
    /**
     Set number of frame file images to create;
     The time interval to create the image is 1000 milli second.
     See setFrameTimeBetweenImages to change the time interval.
     
     - Parameter frameNumberOfImages: The number of images to create;
     */
    @objc
    public func setFrameNumberOfImages(frameNumberOfImages: Int) {
        self.captureOptions.frameNumberOfImages = frameNumberOfImages
    }
    
    /**
     Set saving frame images time interval in milli seconds.
     
     - Parameter frameTimeBetweenImages: The time in milli seconds. Default value is `1000`;
     */
    @objc
    public func setFrameTimeBetweenImages(frameTimeBetweenImages: Int64) {
        self.captureOptions.frameTimeBetweenImages = frameTimeBetweenImages
    }
}
