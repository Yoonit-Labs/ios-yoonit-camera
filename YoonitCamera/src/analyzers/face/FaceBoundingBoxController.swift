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
    func getClosestFace(_ faces: [VNFaceObservation]) -> VNFaceObservation {
        
        // Get the closest face.
        let closestFace = faces.sorted {
            return $0.boundingBox.width > $1.boundingBox.width
            }[0]
                
        return closestFace
    }
    
    /**
     Transform the detected face bounding box coordinates in the UI graphic coordinates, based in the CameraGraphicView and InputImage dimensions.
     
     - Parameter face the detected face bounding box.
     - Parameter cameraInputImage the camera image input with the face detected.
     - Returns: the detection box rect of the detected face. null if face is null or detection box is out of the screen.
     */
    func getDetectionBox(boundingBox: CGRect, imageBuffer: CVPixelBuffer) -> CGRect? {
        
        // Normalize the bounding box coordinates to UI.
        let faceBoundingBox = self.previewLayer
            .layerRectConverted(fromMetadataOutputRect: boundingBox)
            .increase(by: CGFloat(self.captureOptions.facePaddingPercent))
        
        let scale = CGFloat(CVPixelBufferGetWidth(imageBuffer)) / self.cameraView.bounds.width
        let faceBoundingBoxScaled = faceBoundingBox.adjustedBySafeArea(height: self.topSafeHeight / scale)
        
        let left = Int(faceBoundingBoxScaled.minX)
        let top = Int(faceBoundingBoxScaled.minY)
        let right = Int(faceBoundingBoxScaled.maxX)
        let bottom = Int(faceBoundingBoxScaled.maxY)
            
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
       line.lineCap = CAShapeLayerLineCap.round
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
