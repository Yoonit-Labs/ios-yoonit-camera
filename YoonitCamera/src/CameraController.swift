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
    private var session: AVCaptureSession? = nil
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    private var faceAnalyzer: FaceAnalyzer?
    private var barcodeAnalyzer: BarcodeAnalyzer?
    private var frameAnalyzer: FrameAnalyzer?
    
    public var cameraEventListener: CameraEventListenerDelegate? {
        didSet {
            self.faceAnalyzer?.cameraEventListener = cameraEventListener
            self.barcodeAnalyzer?.cameraEventListener = cameraEventListener
            self.frameAnalyzer?.cameraEventListener = cameraEventListener
        }
    }
    
    // Indicates if preview started or not.
    public var isPreviewStarted: Bool = false
    
    init(
        cameraView: CameraView,
        captureOptions: CaptureOptions,
        session: AVCaptureSession,
        previewLayer: AVCaptureVideoPreviewLayer
    ) {
        super.init()
        
        self.session = session
        self.previewLayer = previewLayer
                    
        self.cameraView = cameraView
        self.captureOptions = captureOptions
        
        self.faceAnalyzer = FaceAnalyzer(
            captureOptions: self.captureOptions,
            cameraView: self.cameraView,
            previewLayer: self.previewLayer!,
            session: self.session!)
        
        self.barcodeAnalyzer = BarcodeAnalyzer(session: self.session!)
        
        self.frameAnalyzer = FrameAnalyzer(captureOptions: self.captureOptions, session: self.session!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implementation.")
    }
    
    /**
     Start process camera preview, started with selected camera.
     */
    public func startPreview() {
        
        if (self.isPreviewStarted) {
            return
        }
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            self.cameraEventListener?.onPermissionDenied()
            return
        }
                        
        self.buildCameraInput(cameraLens: self.captureOptions.cameraLens)        
        
        self.session!.sessionPreset = .hd1280x720
        self.session!.startRunning()
        self.isPreviewStarted = true
    }
    
    /**
     Start capture type of Image Analyzer.
     Must have started preview.
     
     - Parameter captureType: `.NONE` | `.FACE` | `.BARCODE` | `.FRAME`;
     - Precondition: Must have started preview.
     */
    public func startCaptureType(captureType: CaptureType) {
                        
        self.captureOptions.type = captureType
        self.stopAnalyzer()
        
        switch self.captureOptions.type {
        case CaptureType.FACE:
            self.faceAnalyzer?.start()
            
        case CaptureType.BARCODE:
            self.barcodeAnalyzer?.start()
            
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
        
        self.barcodeAnalyzer?.stop()
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
        
        if self.session!.isRunning {
            
            // Remove camera input.
            self.session!.inputs.forEach({ self.session!.removeInput($0) })
            
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
     Return selected camera.
     */
    public func getCameraLens() -> Int {
        return self.captureOptions.cameraLens.rawValue
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
                self.cameraEventListener?.onError(error: "You have a problem with your camera, please verify the settings of the your camera")
                fatalError("No back camera device found, please make sure to run in an iOS device and not a simulator")
        }
        
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.session!.addInput(cameraInput)
    }
}
