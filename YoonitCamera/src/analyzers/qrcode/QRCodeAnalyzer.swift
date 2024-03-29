/*
 * ██╗   ██╗ ██████╗  ██████╗ ███╗   ██╗██╗████████╗
 * ╚██╗ ██╔╝██╔═══██╗██╔═══██╗████╗  ██║██║╚══██╔══╝
 *  ╚████╔╝ ██║   ██║██║   ██║██╔██╗ ██║██║   ██║
 *   ╚██╔╝  ██║   ██║██║   ██║██║╚██╗██║██║   ██║
 *    ██║   ╚██████╔╝╚██████╔╝██║ ╚████║██║   ██║
 *    ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝
 *
 * https://yoonit.dev - about@yoonit.dev
 *
 * iOS Yoonit Camera
 * The most advanced and modern Camera module for iOS with a lot of awesome features
 *
 * Haroldo Teruya & Márcio Bruffato @ 2020-2021
 */

import AVFoundation
import UIKit
import Vision

class QRCodeAnalyzer {
    
    private var cameraGraphicView: CameraGraphicView
    private var timestamp = Date().currentTimeMillis()
    private var coordinatesController: CoordinatesController
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
        self.coordinatesController = CoordinatesController(cameraGraphicView: cameraGraphicView)
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
            let detectionBox: CGRect = barCodeObject.bounds.scale(
                top: captureOptions.detectionTopSize,
                right: captureOptions.detectionRightSize,
                bottom: captureOptions.detectionBottomSize,
                left: captureOptions.detectionLeftSize
            )
            
            if let error: String = self
                .coordinatesController
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
