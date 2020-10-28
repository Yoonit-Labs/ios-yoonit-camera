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
 Model to set CameraView features options.
 */
public class CaptureOptions {
    var type: CaptureType = .NONE
    
    var cameraLens: AVCaptureDevice.Position = AVCaptureDevice.Position.front
    
    var faceDetectionBox: Bool = true
    var faceNumberOfImages: Int = 0
    var faceTimeBetweenImages: Int64 = 1000
    var facePaddingPercent: Float = 0.27
    var faceImageSize = CGSize(width: 200, height: 200)
}
