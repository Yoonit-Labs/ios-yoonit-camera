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

class FaceBoundingBoxController: NSObject {
    
    private var previewLayer: AVCaptureVideoPreviewLayer
    private var cameraView: CameraView!
    private var captureOptions: CaptureOptions
    public var cameraEventListener: CameraEventListenerDelegate?
    
    private let topSafeHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            return safeFrame.minY > 24 ? safeFrame.minY : 0
        } else {
            return 0
        }
    }()
    
    init(
        captureOptions: CaptureOptions,
        cameraView: CameraView,
        previewLayer: AVCaptureVideoPreviewLayer)
    {
        self.captureOptions = captureOptions
        self.cameraView = cameraView
        self.previewLayer = previewLayer
    }
    
    /**
     Get the closest face bounding box.
     
     - Parameter faces: The face list camera detected;
     - Returns: The closest face.
     */
    func getClosestFaceBoundingBox(_ faces: [VNFaceObservation]) -> CGRect {
        
        // Get the closest face.
        let closestFace = faces.sorted {
            return $0.boundingBox.width > $1.boundingBox.width
            }[0]
        
        // Normalize the bounding box coordinates to UI.
        let faceBoundingBox = self.previewLayer
            .layerRectConverted(fromMetadataOutputRect: closestFace.boundingBox)
            .increase(by: CGFloat(self.captureOptions.facePaddingPercent))
        
        return faceBoundingBox
    }
    
    func getDetectionBox(boundingBox: CGRect, pixelBuffer: CVPixelBuffer) -> CGRect? {
        
        let scale = CGFloat(CVPixelBufferGetWidth(pixelBuffer)) / self.cameraView.bounds.width
        
        let faceBoundingBoxScaled = boundingBox.adjustedBySafeArea(height: self.topSafeHeight / scale)
        
        let left = Int(faceBoundingBoxScaled.minX)
        let top = Int(faceBoundingBoxScaled.minY)
        let right = Int(faceBoundingBoxScaled.maxX)
        let bottom = Int(faceBoundingBoxScaled.maxY)
        
        if
            left < 0 ||
                top < 0 ||
                bottom > Int(UIScreen.main.bounds.height) ||
                right > Int(UIScreen.main.bounds.width)
        {
            return nil
        }
        
        let width = right - left

        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let detectionBoxRelatedWithScreen = Float(width) / Float(self.previewLayer.bounds.width)

        if (detectionBoxRelatedWithScreen < self.captureOptions.faceCaptureMinSize) {
            self.cameraEventListener?.onError(error: KeyError.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue)
            return nil
        }
        if (detectionBoxRelatedWithScreen > self.captureOptions.faceCaptureMaxSize) {
            self.cameraEventListener?.onError(error: KeyError.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue)   
            return nil
        }
        
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    func drawLine(
        onLayer layer: CALayer,
        fromPoint start: CGPoint,
        toPoint end: CGPoint) {
        
       let line = CAShapeLayer()
       let linePath = UIBezierPath()
       linePath.move(to: start)
       linePath.addLine(to: end)
       line.path = linePath.cgPath
       line.fillColor = nil
       line.opacity = 1.0
       line.strokeColor = UIColor.white.cgColor
       line.lineWidth = 6.0
       line.cornerRadius = 20
       line.lineCap = CAShapeLayerLineCap.round // this parameter solve my problem
       layer.addSublayer(line)
    }
    
    func makeShapeFor(boundingBox: CGRect) -> [CAShapeLayer] {
        
        var drawings: [CAShapeLayer] = []
        let faceBoundingBoxPath = CGPath(rect: boundingBox, transform: nil)
        let faceBoundingBoxShape = CAShapeLayer()
        
        faceBoundingBoxShape.path = faceBoundingBoxPath
        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
        faceBoundingBoxShape.strokeColor = UIColor.white.cgColor
        faceBoundingBoxShape.lineWidth = 2
                
        let left = boundingBox.minX
        let top = boundingBox.minY
        let right = boundingBox.maxX
        let bottom = boundingBox.maxY
        let midY = (bottom - top) / 2.0
    
        // edge - top-left > bottom-left
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: left, y: top),
            toPoint: CGPoint(x: left, y: bottom - (midY * 1.5)))

        // edge - top-right > bottom-right
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: right, y: top),
            toPoint: CGPoint(x: right, y: bottom - (midY * 1.5)))
        
        // edge - bottom-left > top-left
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: left, y: bottom),
            toPoint: CGPoint(x: left, y: bottom - (midY * 0.5)))

        // edge - bottom-right > top-right
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: right, y: bottom),
            toPoint: CGPoint(x: right, y: bottom - (midY * 0.5)))

        // edge - top-left > top-right
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: left, y: top),
            toPoint: CGPoint(x: left + (midY * 0.5), y: top))

        // edge - top-right > left-right
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: right, y: top),
            toPoint: CGPoint(x: right - (midY * 0.5), y: top))

        // edge - bottom-left > right-left
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: left, y: bottom),
            toPoint: CGPoint(x: left + (midY * 0.5), y: bottom))

        // edge - bottom-right > right-left
        drawLine(
            onLayer: faceBoundingBoxShape,
            fromPoint: CGPoint(x: right, y: bottom),
            toPoint: CGPoint(x: right - (midY * 0.5), y: bottom))
        
        drawings.append(faceBoundingBoxShape)
        
        return drawings
    }
}
