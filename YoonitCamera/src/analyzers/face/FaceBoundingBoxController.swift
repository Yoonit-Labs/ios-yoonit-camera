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
    private var cameraGraphicView: CameraGraphicView
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
        cameraGraphicView: CameraGraphicView,
        previewLayer: AVCaptureVideoPreviewLayer
    ) {                
        self.cameraGraphicView = cameraGraphicView
        self.previewLayer = previewLayer
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
            .increase(by: CGFloat(captureOptions.facePaddingPercent))
        
        if faceBoundingBox.isNaN() {
            return nil
        }
        
        let scale = CGFloat(CVPixelBufferGetWidth(imageBuffer)) / self.cameraGraphicView.bounds.width
        let faceBoundingBoxScaled = faceBoundingBox.adjustedBySafeArea(height: self.topSafeHeight / scale)
        
        let left = Int(faceBoundingBoxScaled.minX)
        let top = Int(faceBoundingBoxScaled.minY)
        let right = Int(faceBoundingBoxScaled.maxX)
        let bottom = Int(faceBoundingBoxScaled.maxY)
            
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    /**
     Get the error message if exist based in the capture options rules and the detection box.
     
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
        if (detectionBoxRelatedWithScreen < captureOptions.faceCaptureMinSize) {
            return Message.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue
        }
        
        // Face bigger than the capture maximum size.
        if (detectionBoxRelatedWithScreen > captureOptions.faceCaptureMaxSize) {
            return Message.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue
        }
        
        if captureOptions.faceROI.enable {
            
            // Detection box offsets.
            let topOffset = Float(detectionBox!.minY / screenHeight)
            let rightOffset = Float((screenWidth - detectionBox!.maxX) / screenWidth)
            let bottomOffset = Float((screenHeight - detectionBox!.maxY) / screenHeight)
            let leftOffset = Float(detectionBox!.minX / screenWidth)
            
            if captureOptions.faceROI.isOutOf(
                topOffset: topOffset,
                rightOffset: rightOffset,
                bottomOffset: bottomOffset,
                leftOffset: leftOffset) {
                                
                return Message.INVALID_CAPTURE_FACE_OUT_OF_ROI.rawValue
            }
            
            if captureOptions.faceROI.hasChanges {
                
                // Face is inside the region of interest and faceROI is setted.
                // Face is smaller than the defined "minimumSize".
                let roiWidth: Float =
                    Float(screenWidth) -
                    ((captureOptions.faceROI.rightOffset + captureOptions.faceROI.leftOffset) *
                        Float(screenWidth))
                
                let faceRelatedWithROI: Float = Float(detectionBox!.width) / roiWidth
                                                    
                if captureOptions.faceROI.minimumSize > faceRelatedWithROI {
                    return Message.INVALID_CAPTURE_FACE_ROI_MIN_SIZE.rawValue
                }
            }
        }
        
        return nil
    }
}
