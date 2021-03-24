//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya @ Cyberlabs AI 2020-2021                         |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//

import AVFoundation
import UIKit
import Vision

class QRCodeAnalyzer {
    
    private var cameraGraphicView: CameraGraphicView
    private var timestamp = Date().currentTimeMillis()
    private var faceCoordinatesController: FaceCoordinatesController
    private var isValid = true
    
    public var cameraEventListener: CameraEventListenerDelegate?
    public var start: Bool = false {
        didSet {
            self.cameraGraphicView.draw = self.start
        }
    }
    
    init(
        cameraGraphicView: CameraGraphicView
    ) {
        self.cameraGraphicView = cameraGraphicView
        self.faceCoordinatesController = FaceCoordinatesController(
            cameraGraphicView: cameraGraphicView
        )
    }
    
    public func qrcodeDetect(metadataObjects: [AVMetadataObject]) {
        
        self.detect(metadataObjects: metadataObjects) {
            value, detectionBox in
            
            self.isValid = true
            self.cameraGraphicView.handleDraw(detectionBox: detectionBox)
            self.cameraEventListener?.onQRCodeScanned(value)
            
        } onError: {
            error in
                        
            if error != nil && error != "" && self.isValid {
                self.isValid = false
                self.cameraEventListener?.onMessage(error!)
            }
            self.cameraGraphicView.clear()
        }
    }
    
    private func detect(
        metadataObjects: [AVMetadataObject],
        onSuccess: @escaping (String, CGRect) -> Void,
        onError: @escaping (String?) -> Void
    ) {
        if metadataObjects.isEmpty {
            onError("")
            return
        }
        
        let closestQRCode: AVMetadataObject = metadataObjects.sorted {
            return $0.bounds.width > $1.bounds.width
            }[0]
        
        guard let readableObject = closestQRCode as? AVMetadataMachineReadableCodeObject else {
            onError("")
            return
        }
        
        guard let value = readableObject.stringValue else {
            onError("")
            return
        }
        
        let currentTimestamp = Date().currentTimeMillis()
        let diffTime = currentTimestamp - self.timestamp
        if diffTime <= 100 {
            return
        }
        self.timestamp = currentTimestamp
        
        if let barCodeObject: AVMetadataObject = previewLayer.transformedMetadataObject(for: closestQRCode) {
            let detectionBox: CGRect = barCodeObject.bounds
            
            if let error: String = self
                .faceCoordinatesController
                .hasFaceDetectionBoxError(detectionBox: detectionBox)
            {
                onError(error)
            } else {
                onSuccess(value, detectionBox)
            }
        } else {
            onError("")
        }
    }
}
