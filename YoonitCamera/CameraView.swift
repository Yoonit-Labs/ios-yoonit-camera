//
//  CameraView.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 03/09/20.
//

import Foundation
import AVFoundation
import UIKit

@objc
public class CameraView: UIView {
    
    private var captureOptions: CaptureOptions = CaptureOptions()
    private var cameraController: CameraControllerProtocol?
    
    @objc
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.cameraController?.cameraEventListener = cameraEventListener
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cameraController = CameraController(cameraView: self, captureOptions: captureOptions)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.cameraController = CameraController(cameraView: self, captureOptions: captureOptions)        
    }
            
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.cameraController != nil) {
            self.cameraController?.layoutSubviews()
        }
    }
    
    @objc
    public func startPreview() {
        self.cameraController?.startPreview()
    }
    
    @objc
    public func startCaptureType(captureType: String) {
        if (captureType == "none") {
            self.cameraController?.startCaptureType(captureType: CaptureType.NONE)
            return
        }
        
        if (captureType == "face") {
            self.cameraController?.startCaptureType(captureType: CaptureType.FACE)
            return
        }
        
        if (captureType == "barcode") {
            self.cameraController?.startCaptureType(captureType: CaptureType.BARCODE)
            return
        }
        
        if (self.cameraEventListener != nil) {
            self.cameraEventListener?.onError(error: "Input " + captureType + " invalid.")
        }
    }
    
    @objc
    public func stopCapture() {
        self.cameraController?.stopAnalyzer()
    }
    
    @objc
    public func pauseCapture() {
        self.cameraController?.pauseAnalyzer()
    }
    
    @objc
    public func resumeCapture() {
        self.cameraController?.resumeAnalyzer()
    }
        
    @objc
    public func toggleCameraLens() {
        self.cameraController!.toggleCameraLens()
    }
    
    @objc
    public func getCameraLens() -> Int {
        return (self.cameraController?.getCameraLens())!
    }
    
    @objc
    public func setFaceNumberOfImages(faceNumberOfImages: Int) {
        self.captureOptions.faceNumberOfImages = faceNumberOfImages
    }
    
    @objc
    public func setFaceDetectionBox(faceDetectionBox: Bool) {
        self.captureOptions.faceDetectionBox = faceDetectionBox
    }
    
    @objc
    public func setFaceTimeBetweenImages(faceTimeBetweenImages: Int64) {
        self.captureOptions.faceTimeBetweenImages = faceTimeBetweenImages
    }
    
    @objc
    public func setFacePaddingPercent(facePaddingPercent: Float) {
        self.captureOptions.facePaddingPercent = facePaddingPercent
    }
    
    @objc
    public func setFaceImageSize(faceImageSizeHeight: Int, faceImageSizeWidth: Int) {
        self.captureOptions.faceImageSizeHeight = faceImageSizeHeight
        self.captureOptions.faceImageSizeWidth = faceImageSizeWidth
    }
}
