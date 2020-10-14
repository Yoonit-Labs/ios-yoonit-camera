//
//  CameraController.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 03/09/20.
//

import AVFoundation
import UIKit
import Vision

class CameraController: NSObject, CameraControllerProtocol {
    
    private var cameraView: CameraView!
    
    // manages multiple inputs and outputs of audio and video.
    private var session = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var cameraLensFacing: AVCaptureDevice.Position = AVCaptureDevice.Position.front
    
    private var captureType: CaptureType = .NONE
    private var faceAnalyzer: FaceAnalyzer?
    private var barcodeAnalyzer: BarcodeAnalyzer?
    
    public var captureOptions: CaptureOptions?
    
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.faceAnalyzer?.cameraEventListener = cameraEventListener
            self.barcodeAnalyzer?.cameraEventListener = cameraEventListener
        }
    }
    
    init(cameraView: CameraView, captureOptions: CaptureOptions) {
        super.init()
        
        self.cameraView = cameraView
        self.captureOptions = captureOptions
        
        self.faceAnalyzer = FaceAnalyzer(
            captureOptions: self.captureOptions,
            cameraView: self.cameraView,
            previewLayer: self.previewLayer,
            session: self.session,
            cameraCallBack: self)
        
        self.barcodeAnalyzer = BarcodeAnalyzer(session: self.session)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implementation.")
    }
    
    /*
     Start process camera preview, started with selected camera.
     */
    public func startPreview() {
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            self.cameraEventListener?.onPermissionDenied()
            return
        }
        
        self.buildCameraInput(cameraLens: self.cameraLensFacing)
        
        // Show camera feed.
        self.previewLayer.videoGravity = .resizeAspectFill
        if (self.cameraView != nil) {
            self.cameraView.layer.addSublayer(self.previewLayer)
        }
        self.session.sessionPreset = .hd1280x720
        self.session.startRunning()
    }
    
    /*
     Set which is the capture type: Barcode or Face.
     */
    public func startCaptureType(captureType: CaptureType) {
        if !self.session.isRunning {
            self.cameraEventListener?.onMessage(message: "Camera Preview not started")
            return
        }
        
        self.stopAnalyzer()
        
        if (captureType == .BARCODE) {
            self.captureType = .BARCODE
            self.barcodeAnalyzer?.start()
            return
        }
        
        if (captureType == .FACE) {
            self.captureType = .FACE
            self.faceAnalyzer?.cameraLensFacing = self.cameraLensFacing
            self.faceAnalyzer?.start()
            return
        }
    }
    
    public func stopAnalyzer() {
        self.faceAnalyzer?.stop()
        self.faceAnalyzer?.numCapturedImages = 0
        
        self.barcodeAnalyzer?.stop()
    }
            
    public func layoutSubviews() {
        if (self.cameraView != nil) {
            self.previewLayer.frame = self.cameraView.bounds
        }
    }
    
    /*
     Change the front camera by the back camera
     */
    public func toggleCameraLens() {
        if !self.session.isRunning {
            self.cameraEventListener?.onMessage(message: "Camera Preview not started")
            return
        }
        
        if (self.cameraLensFacing == .front) {
            self.cameraLensFacing = .back
        } else {
            self.cameraLensFacing = .front
        }
        
        // Remove camera input.
        self.session.inputs.forEach({ self.session.removeInput($0) })
        
        // Add camera input.
        self.buildCameraInput(cameraLens: self.cameraLensFacing)
        
        if (self.captureType == .FACE) {
            self.faceAnalyzer?.cameraLensFacing = self.cameraLensFacing
            self.faceAnalyzer?.reset()
        }
    }
    
    /*
     Return selected camera.
     */
    public func getCameraLens() -> Int {
        return self.cameraLensFacing.rawValue
    }
    
    /*
     Start camera preview with selected camera.
     */
    private func buildCameraInput(cameraLens: AVCaptureDevice.Position) {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: cameraLens).devices.first
        else {
            self.cameraEventListener?.onError(error: "You have a problem with your camera, please verify the settings of the your camera")
            fatalError("No back camera device found, please make sure to run in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.session.addInput(cameraInput)
    }
}

extension CameraController: CameraCallBackDelegate {
    
    func onStopAnalyzer() {
        self.stopAnalyzer()
    }
}
