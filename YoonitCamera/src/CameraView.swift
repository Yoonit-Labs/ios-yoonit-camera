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
    
    private var captureOptions: CaptureOptions = CaptureOptions()
    private var cameraController: CameraControllerProtocol?
    
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
    UIView update layout and subviews. Used to update camera controller subviews.
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
    Start capture type: none, face or barcode.
    Must have started preview, see `startPreview.

    - Parameters: `"none`" | `"face`" | `"barcode`";
    - Precondition: value string must be one of `"none"`, `"face`" or `"barcode`";
     */
    @objc
    public func startCaptureType(captureType: String) {
        
        if (captureType == "none") {
            self.cameraController?.startCaptureType(captureType: CaptureType.NONE)
            return
        }
        if (captureType == "face") {
            self.cameraController?.startCaptureType(captureType: CaptureType.FACE)
            return
        }
        if (captureType == "barcode") {
            self.cameraController?.startCaptureType(captureType: CaptureType.BARCODE)
            return
        }
        if (self.cameraEventListener != nil) {
            self.cameraEventListener?.onError(error: "Input \(captureType) invalid.")
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
    See [setFaceTimeBetweenImages] to change the time interval.

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
}
