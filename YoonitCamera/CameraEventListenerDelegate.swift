//
//  CameraEventLitener.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 03/09/20.
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
}
