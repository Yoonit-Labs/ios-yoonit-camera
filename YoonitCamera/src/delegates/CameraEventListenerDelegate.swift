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

    func onFaceImageCreated(
        count: Int,
        total: Int,
        imagePath: String)

    func onFaceDetected(
        x: Int,
        y: Int,
        width: Int,
        height: Int)
    
    func onFaceUndetected()

    func onEndCapture()

    func onError(error: String)

    func onMessage(message: String)

    func onPermissionDenied()

    func onBarcodeScanned(content: String)
    
    func onFrameImageCreated(
        count: Int,
        total: Int,
        imagePath: String)
}
