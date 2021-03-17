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
        _ leftEyeOpenProbability: Float,
        _ hasLeftEyeOpenProbability: Bool,
        _ rightEyeOpenProbability: Float,
        _ hasRightEyeOpenProbability: Bool,
        _ smilingProbability: Float,
        _ hasSmilingProbability: Bool,
        _ headEulerAngleX: Float,
        _ hasHeadEulerAngleX: Bool,
        _ headEulerAngleY: Float,
        _ hasHeadEulerAngleY: Bool,
        _ headEulerAngleZ: Float,
        _ hasHeadEulerAngleZ: Bool
    )
    
    func onFaceUndetected()

    func onEndCapture()

    func onError(_ error: String)

    func onMessage(_ message: String)

    func onPermissionDenied()

    func onQRCodeScanned(_ content: String)
}
