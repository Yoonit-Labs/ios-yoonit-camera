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

/**
This class is responsible to handle the operations related with the barcode capture.
*/
class BarcodeAnalyzer: NSObject {
    
    public var cameraEventListener: CameraEventListenerDelegate?
    
    private var session: AVCaptureSession?
    
    init(session: AVCaptureSession) {
        self.session = session
    }
    
    func start() {
        let metadataOutput = AVCaptureMetadataOutput()
        
        self.session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    }
    
    func stop() {
        self.session?.outputs.forEach({ self.session?.removeOutput($0) })
    }
}

extension BarcodeAnalyzer: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.cameraEventListener?.onBarcodeScanned(content: stringValue)
        }
    }
}
