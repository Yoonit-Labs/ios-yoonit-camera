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

public protocol CameraControllerProtocol {
    func layoutSubviews()
    func startPreview()
    func stopAnalyzer()    
    func toggleCameraLens()
    func getCameraLens() -> Int
    func startCaptureType(captureType: CaptureType)
    var cameraEventListener: CameraEventListenerDelegate? { get set }
    var captureOptions: CaptureOptions? { get set }
}
