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
 This class is responsible to build closest face, detection box and draw a bounding box.
 
 Closest face is based on the bounding box width size.
 Detection box is based on the closest face bounding box coordinates normalized to UI.
 */
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
        previewLayer: AVCaptureVideoPreviewLayer) {
        
        self.captureOptions = captureOptions
        self.cameraView = cameraView
        self.previewLayer = previewLayer
    }
    
    /**
     Get the closest face bounding box.
     
     - Parameter faces: The face list camera detected;
     - Returns: The closest face.
     */
    public func getClosestFace(_ faces: [VNFaceObservation]) -> VNFaceObservation {
        
        // Get the closest face.
        let closestFace = faces.sorted {
            return $0.boundingBox.width > $1.boundingBox.width
            }[0]
                
        return closestFace
    }
    
    /**
     Transform the detected face bounding box coordinates in the UI graphic coordinates, based in the CameraGraphicView and InputImage dimensions.
     
     - Parameter boundingBox: the detected face bounding box.
     - Parameter imageBuffer the camera image input with the face detected.
     - Returns: the detection box rect of the detected face. Null or detection box is out of the screen.
     */
    public func getDetectionBox(boundingBox: CGRect, imageBuffer: CVPixelBuffer) -> CGRect? {
        
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
    
    /**
     Validade the face detection box coordinates based in the capture options rules.
     
     - Parameter detectionBox: the face detection box coordinates.
     - Returns: `nil` for no error:
        INVALID_CAPTURE_FACE_MIN_SIZE
        INVALID_CAPTURE_FACE_MAX_SIZE
        INVALID_CAPTURE_FACE_OUT_OF_ROI
        INVALID_CAPTURE_FACE_ROI_MIN_SIZE
     */
    public func getError(detectionBox: CGRect?) -> String? {
        
        if detectionBox == nil {
            return ""
        }
        
        let screenWidth = self.previewLayer.bounds.width
        let screenHeight = self.previewLayer.bounds.height
                           
        // Face is out of the screen.
        let isOutOfTheScreen =
            detectionBox!.minX < 0 ||
            detectionBox!.minY < 0 ||
            detectionBox!.maxY > screenHeight ||
            detectionBox!.maxX > screenWidth
        if isOutOfTheScreen {
            return ""
        }
        
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let detectionBoxRelatedWithScreen = Float(detectionBox!.width / screenWidth)

        // Face smaller than the capture minimum size.
        if (detectionBoxRelatedWithScreen < self.captureOptions.faceCaptureMinSize) {
            return Message.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue
        }
        
        // Face bigger than the capture maximum size.
        if (detectionBoxRelatedWithScreen > self.captureOptions.faceCaptureMaxSize) {
            return Message.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue
        }
        
        if self.captureOptions.faceROI.enable {
            
            // Detection box offsets.
            let topOffset = Float(detectionBox!.minY / screenHeight)
            let rightOffset = Float((screenWidth - detectionBox!.maxX) / screenWidth)
            let bottomOffset = Float((screenHeight - detectionBox!.maxY) / screenHeight)
            let leftOffset = Float(detectionBox!.minX / screenWidth)
            
            if self.captureOptions.faceROI.isOutOf(
                topOffset: topOffset,
                rightOffset: rightOffset,
                bottomOffset: bottomOffset,
                leftOffset: leftOffset) {
                                
                return Message.INVALID_CAPTURE_FACE_OUT_OF_ROI.rawValue
            }
            
            if self.captureOptions.faceROI.hasChanges {
                
                // Face is inside the region of interest and faceROI is setted.
                // Face is smaller than the defined "minimumSize".
                let roiWidth: Float =
                    Float(screenWidth) -
                    ((self.captureOptions.faceROI.rightOffset + self.captureOptions.faceROI.leftOffset) *
                        Float(screenWidth))
                
                let faceRelatedWithROI: Float = Float(detectionBox!.width) / roiWidth
                                                    
                if self.captureOptions.faceROI.minimumSize > faceRelatedWithROI {
                    return Message.INVALID_CAPTURE_FACE_ROI_MIN_SIZE.rawValue
                }
            }
        }
        
        return nil
    }
    
    public func drawLine(
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
    
    public func makeShapeFor(boundingBox: CGRect) -> [CAShapeLayer] {
        
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
