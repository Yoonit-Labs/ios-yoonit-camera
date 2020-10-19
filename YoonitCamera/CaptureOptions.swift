//
//  CaptureOptions.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 03/09/20.
//

import Foundation
import AVFoundation

public class CaptureOptions {
    var faceNumberOfImages: Int = 0
    var faceTimeBetweenImages: Int64 = 1000
    var facePaddingPercent: Float = 0.27
    var faceImageSizeWidth: Int = 200
    var faceImageSizeHeight: Int = 200
    var faceDetectionBox: Bool = true
    var cameraLensFacing: AVCaptureDevice.Position = AVCaptureDevice.Position.front
}
