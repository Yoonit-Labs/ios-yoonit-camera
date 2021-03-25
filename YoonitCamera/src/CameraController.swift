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

import AVFoundation
import UIKit
import Vision

/**
 Class responsible to handle the camera operations.
 */
class CameraController: NSObject {
                        
    // Manages multiple inputs and outputs of audio and video.
    private var session: AVCaptureSession    
    private var cameraGraphicView: CameraGraphicView
    private var faceAnalyzer: FaceAnalyzer?
    private var frameAnalyzer: FrameAnalyzer?
    private var qrcodeAnalyzer: QRCodeAnalyzer?
    
    public var cameraEventListener: CameraEventListenerDelegate? = nil {
        didSet {
            self.faceAnalyzer?.cameraEventListener = cameraEventListener
            self.frameAnalyzer?.cameraEventListener = cameraEventListener
            self.qrcodeAnalyzer?.cameraEventListener = cameraEventListener
        }
    }
    
    // Indicates if preview started or not.
    public var isPreviewStarted: Bool = false
    
    init(
        session: AVCaptureSession,
        cameraGraphicView: CameraGraphicView
    ) {
        self.session = session
        self.cameraGraphicView = cameraGraphicView
        
        self.faceAnalyzer = FaceAnalyzer(cameraGraphicView: cameraGraphicView)
        self.frameAnalyzer = FrameAnalyzer()
        self.qrcodeAnalyzer = QRCodeAnalyzer(cameraGraphicView: cameraGraphicView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implementation.")
    }
    
    /**
     Start process camera preview.
     */
    public func startPreview() {
        
        // Do not try start preview if already exist a preview started.
        // Can not use session.isRunning because it is not valid when application is in background.
        if (self.isPreviewStarted) {
            return
        }
        
        // Do not try to start preview if application does not have permission.
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            self.cameraEventListener?.onPermissionDenied()
            return
        }
                        
        // Build camera input based on the camera lens.
        self.buildCameraInput(cameraLens: captureOptions.cameraLens)
                
        // Start running the session.
        self.session.startRunning()
        self.isPreviewStarted = true
    }
    
    /**
     Stop analyzers, remove session inputs, remove session outputs and stop session.
     */
    public func destroy() {
        self.stopAnalyzer()
        
        // Remove camera input and output.
        self.session.inputs.forEach({ self.session.removeInput($0) })
        self.session.outputs.forEach({ self.session.removeOutput($0) })
                        
        // Stop running the session.
        self.session.stopRunning()
        self.isPreviewStarted = false
    }
    
    /**
     Start capture type of Image Analyzer.
     Must have started preview.
     
     - Parameter captureType: `.NONE` | `.FACE` | `.QRCODE` | `.FRAME`;
     - Precondition: Must have started preview.
     */
    public func startCaptureType(captureType: CaptureType) {
                        
        captureOptions.type = captureType
        self.stopAnalyzer()
        
        switch captureOptions.type {
        case CaptureType.FACE:
            self.faceAnalyzer?.start = true
            
        case CaptureType.FRAME:
            self.frameAnalyzer?.start = true
            
        case CaptureType.QRCODE:
            self.qrcodeAnalyzer?.start = true
            
        default:
            return
        }
    }
    
    /**
     Stop camera image analyzer and clear camera graphic view.
     */
    public func stopAnalyzer() {
        self.faceAnalyzer?.start = false
        self.frameAnalyzer?.start = false
        self.qrcodeAnalyzer?.start = false
    }
        
    /**
     Toggle between Front and Back Camera.
     */
    public func toggleCameraLens() {
        if (captureOptions.cameraLens == .front) {
            captureOptions.cameraLens = .back
        } else {
            captureOptions.cameraLens = .front
        }
        
        if self.session.isRunning {
            
            // Remove camera input and output.
            self.session.inputs.forEach({ self.session.removeInput($0) })
            self.session.outputs.forEach({ self.session.removeOutput($0) })
            
            // Add camera input.
            self.buildCameraInput(cameraLens: captureOptions.cameraLens)
        }
    }
    
    /**
     Start camera preview with selected camera.
     
     - Parameter cameraLens: the enum of the camera lens facing;
     */
    private func buildCameraInput(cameraLens: AVCaptureDevice.Position) {
        
        self.faceAnalyzer?.numberOfImages = 0
        self.frameAnalyzer?.numberOfImages = 0
        
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: cameraLens
        ).devices.first else {
            return
        }
                
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.session.addInput(cameraInput)
        
        // Video output capture =========================================
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings =
            [(kCVPixelBufferPixelFormatTypeKey as NSString) :
            NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "analyzer_queue")
        )
                        
        self.session.addOutput(videoDataOutput)
        
        // QRCode output capture ========================================
        let metadataOutput = AVCaptureMetadataOutput()
        self.session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(
            self,
            queue: DispatchQueue.main
        )
        metadataOutput.metadataObjectTypes = [.qr]
        
        // Connection handler.
        guard let connection = videoDataOutput.connection(
            with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    func setTorch(enable: Bool) {
        if let device = AVCaptureDevice.default(for: .video) {
            if device.hasTorch && captureOptions.cameraLens == AVCaptureDevice.Position.back {
                try! device.lockForConfiguration()
                device.torchMode = enable ? .on : .off
                device.unlockForConfiguration()
            }
        }
    }
}

/**
 Camera frame output capture.
 */
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
                
        switch captureOptions.type {
        case CaptureType.FACE:
            self.faceAnalyzer?.faceDetect(imageBuffer: frame)
            
        case CaptureType.FRAME:
            self.frameAnalyzer?.frameCaptured(imageBuffer: frame)
            
        default:
            return
        }
    }
}

/**
 Camera metadata output capture.
 */
extension CameraController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if (captureOptions.type != CaptureType.QRCODE) {
            return
        }
        
        self.qrcodeAnalyzer?.qrcodeDetect(metadataObjects: metadataObjects)
    }
}
