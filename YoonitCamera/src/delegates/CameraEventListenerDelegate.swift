/*
 * ██╗   ██╗ ██████╗  ██████╗ ███╗   ██╗██╗████████╗
 * ╚██╗ ██╔╝██╔═══██╗██╔═══██╗████╗  ██║██║╚══██╔══╝
 *  ╚████╔╝ ██║   ██║██║   ██║██╔██╗ ██║██║   ██║
 *   ╚██╔╝  ██║   ██║██║   ██║██║╚██╗██║██║   ██║
 *    ██║   ╚██████╔╝╚██████╔╝██║ ╚████║██║   ██║
 *    ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝
 *
 * https://yoonit.dev - about@yoonit.dev
 *
 * iOS Yoonit Camera
 * The most advanced and modern Camera module for iOS with a lot of awesome features
 *
 * Haroldo Teruya & Márcio Bruffato @ 2020-2021
 */

import Foundation

@objc
public protocol CameraEventListenerDelegate {

    func onImageCaptured(
        _ type: String,
        _ count: Int,
        _ total: Int,
        _ imagePath: String,
        _ darkness: NSNumber?,
        _ lightness: NSNumber?,
        _ sharpness: NSNumber?
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
