//
//  CameraControllerProtocol.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 08/09/20.
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
