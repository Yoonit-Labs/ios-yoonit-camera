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

import UIKit
import Foundation
import AVFoundation

/**
 This class is a singleton used in the entire project to handle the features.
 */
public class CaptureOptions {
    
    // Region of interesting.
    var roi: ROI = ROI()
    
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
    
    // Draw or not the face/qrcode detection box.
    var detectionBox: Bool = false
                
    // Detection box color.
    var detectionBoxColor: UIColor = UIColor(
        red: 1.0,
        green: 1.0,
        blue: 1.0,
        alpha: 1.0
    )
    
    /**
     Face/qrcode minimum size to detect in percentage related with the camera preview.
     This variable is the detection box percentage in relation with the UI graphic view.
     The value must be between `0` and `1`.
     */
    var minimumSize: Float = 0
    
    /**
     Face/qrcode maximum size to detect in percentage related with the camera preview.
     This variable is the detection box percentage in relation with the UI graphic view.
     The value must be between `0` and `1`.
     */
    var maximumSize: Float = 1.0
    
    var detectionTopSize: Float = 0.0
    var detectionRightSize: Float = 0.0
    var detectionBottomSize: Float = 0.0
    var detectionLeftSize: Float = 0.0
    
    // Face contours.
    var faceContours: Bool = false

    // Face contours color.
    var faceContoursColor: UIColor = UIColor(
        red: 1.0,
        green: 1.0,
        blue: 1.0,
        alpha: 1.0
    )
}
