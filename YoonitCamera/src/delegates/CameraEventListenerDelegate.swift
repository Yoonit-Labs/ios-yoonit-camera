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

@objc
public protocol CameraEventListenerDelegate {

    func onImageCaptured(
        _ type: String,
        _ count: Int,
        _ total: Int,
        _ imagePath: String
    )

    func onFaceDetected(
        _ x: Int,
        _ y: Int,
        _ width: Int,
        _ height: Int,
        _ leftEyeOpenProbability: NSNumber?,
        _ rightEyeOpenProbability: NSNumber?,
        _ smilingProbability: NSNumber?,
        _ headEulerAngleX: NSNumber?,
        _ headEulerAngleY: NSNumber?,
        _ headEulerAngleZ: NSNumber?
    )
    
    func onFaceUndetected()

    func onEndCapture()

    func onError(_ error: String)

    func onMessage(_ message: String)

    func onPermissionDenied()

    func onQRCodeScanned(_ content: String)
}
