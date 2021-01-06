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


import AVFoundation
import UIKit
import Vision

/**
 Class responsible to handle the camera operations.
 */
class CameraController: NSObject {
    
    // Reference to camera view used to draw bounding box.
    private var cameraView: CameraView!
    
    // Model to set CameraView features options.
    public var captureOptions: CaptureOptions!
        
    // Manages multiple inputs and outputs of audio and video.
    private var session: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer
    
    private var faceAnalyzer: FaceAnalyzer?
    private var frameAnalyzer: FrameAnalyzer?
    
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.faceAnalyzer?.cameraEventListener = cameraEventListener
            self.frameAnalyzer?.cameraEventListener = cameraEventListener
        }
    }
    
    // Indicates if preview started or not.
    public var isPreviewStarted: Bool = false
    
    init(
        cameraView: CameraView,
        captureOptions: CaptureOptions,
        session: AVCaptureSession,
        previewLayer: AVCaptureVideoPreviewLayer) {
        
        self.session = session
        self.previewLayer = previewLayer
                    
        self.cameraView = cameraView
        self.captureOptions = captureOptions
        
        self.faceAnalyzer = FaceAnalyzer(
            captureOptions: self.captureOptions,
            cameraView: self.cameraView,
            previewLayer: self.previewLayer)
        
        self.frameAnalyzer = FrameAnalyzer(captureOptions: self.captureOptions)
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
        self.buildCameraInput(cameraLens: self.captureOptions.cameraLens)        
                
        // Start running the session.
        self.session.startRunning()
        self.isPreviewStarted = true
    }
    
    /**
     Start capture type of Image Analyzer.
     Must have started preview.
     
     - Parameter captureType: `.NONE` | `.FACE` | `.QRCODE` | `.FRAME`;
     - Precondition: Must have started preview.
     */
    public func startCaptureType(captureType: CaptureType) {
                        
        self.captureOptions.type = captureType
        self.stopAnalyzer()
        
        switch self.captureOptions.type {
        case CaptureType.FACE:
            self.faceAnalyzer?.start()
            
        case CaptureType.FRAME:
            self.frameAnalyzer?.start()
            
        default:
            return
        }
    }
    
    /**
     Stop camera image analyzer and clear drawings.
     */
    public func stopAnalyzer() {
        self.faceAnalyzer?.stop()
        self.faceAnalyzer?.numberOfImages = 0
        
        self.frameAnalyzer?.stop()
    }
        
    /**
     Toggle between Front and Back Camera.
     */
    public func toggleCameraLens() {
        if (self.captureOptions.cameraLens == .front) {
            self.captureOptions.cameraLens = .back
        } else {
            self.captureOptions.cameraLens = .front
        }
        
        if self.session.isRunning {
            
            // Remove camera input and output.
            self.session.inputs.forEach({ self.session.removeInput($0) })
            self.session.outputs.forEach({ self.session.removeOutput($0) })
            
            // Add camera input.
            self.buildCameraInput(cameraLens: self.captureOptions.cameraLens)
                                    
            switch self.captureOptions.type {
            case CaptureType.FACE:
                self.faceAnalyzer?.reset()
                
            case CaptureType.FRAME:
                self.frameAnalyzer?.reset()
                
            default:
                return
            }
        }
    }
    
    /**
     Start camera preview with selected camera.
     
     - Parameter cameraLens: the enum of the camera lens facing;
     */
    private func buildCameraInput(cameraLens: AVCaptureDevice.Position) {
        
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: cameraLens).devices.first
            else {
                self.cameraEventListener?.onError("You have a problem with your camera, please verify the settings of the your camera")
                fatalError("No back camera device found, please make sure to run in an iOS device and not a simulator")
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
            queue: DispatchQueue(label: "analyzer_queue"))
                        
        self.session.addOutput(videoDataOutput)
        
        // QRCode output capture ========================================
        let metadataOutput = AVCaptureMetadataOutput()
        self.session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(
            self,
            queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        // Connection handler.
        guard let connection = videoDataOutput.connection(
            with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
}

/**
 Camera frame output capture.
 */
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
                        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.cameraEventListener?.onError("Unable to get image from sample buffer.")
            debugPrint("Unable to get image from sample buffer.")
            return
        }
                
        switch self.captureOptions.type {
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
        from connection: AVCaptureConnection) {

        if (self.captureOptions.type != CaptureType.QRCODE) {
            return
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.cameraEventListener?.onQRCodeScanned(stringValue)
        }
    }
}
