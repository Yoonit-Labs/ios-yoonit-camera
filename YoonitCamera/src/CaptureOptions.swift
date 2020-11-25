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

/**
 Model to set capture features options.
 */
public class CaptureOptions {
    // Camera image capture type: NONE, FACE, BARCODE and FRAME.
    var type: CaptureType = .NONE
    
    // Camera lens facing: CameraSelector.LENS_FACING_FRONT and CameraSelector.LENS_FACING_BACK.
    var cameraLens: AVCaptureDevice.Position = AVCaptureDevice.Position.front
    
    // Draw or not the face detection box.
    var faceDetectionBox: Bool = true
    
    // Face save cropped images.
    var faceSaveImages: Bool = false
    
    // Face capture number of images. 0 capture unlimited.
    var faceNumberOfImages: Int = 0
    
    // Face capture time between images in milliseconds.
    var faceTimeBetweenImages: Int64 = 1000
    
    // Face capture padding percent.
    var facePaddingPercent: Float = 0.27
    
    // Face capture image size to save.
    var faceImageSize = CGSize(width: 200, height: 200)
    
    /**
     Face capture min size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.
     */
    var faceCaptureMinSize: Float = 0
    
    /**
     Face capture maximum size.
     This variable is the face detection box percentage in relation with the UI graphic view.
     The value must be between 0 and 1.   
     */
    var faceCaptureMaxSize: Float = 1.0
    
    // Frame capture number of images. 0 capture unlimited.
    var frameNumberOfImages: Int = 0
    
    // Frame capture time between images in milliseconds.
    var frameTimeBetweenImages: Int64 = 1000
}
