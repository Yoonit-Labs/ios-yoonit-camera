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

import UIKit
import Foundation
import AVFoundation

/**
 This class is a singleton used in the entire project to handle the features.
 */
public class CaptureOptions {
    
    // Face region of interesting. Default is all the screen area.
    var faceROI: FaceROI = FaceROI()
    
    // Camera image capture type: NONE, FACE, BARCODE and FRAME.
    var type: CaptureType = .NONE
    
    // Camera lens facing: CameraSelector.LENS_FACING_FRONT and CameraSelector.LENS_FACING_BACK.
    var cameraLens: AVCaptureDevice.Position = AVCaptureDevice.Position.front
    
    // Face/Frame capture number of images. 0 capture unlimited.
    var numberOfImages: Int = 0

    // Face/Frame capture time between images in milliseconds.
    var timeBetweenImages: Int64 = 1000
        
    // Face/Frame capture image width to create.
    var imageOutputWidth: Int = 200

    // Face/Frame capture image height to create.
    var imageOutputHeight: Int = 200
    
    // Face/Frame save images captured.
    var saveImageCaptured: Bool = false
    
    // Draw or not the face detection box.
    var faceDetectionBox: Bool = false
            
    // Face contours.
    var faceContours: Bool = false

    // Face contours color.
    var faceContoursColor: UIColor = UIColor(
        red: 1.0,
        green: 1.0,
        blue: 1.0,
        alpha: 1.0
    )
    
    // Face capture padding percent.
    var facePaddingPercent: Float = 0.27
        
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
}
