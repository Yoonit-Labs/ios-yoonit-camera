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
    private var cameraGraphicView: CameraGraphicView
    public var cameraEventListener: CameraEventListenerDelegate?
        
    init(
        cameraGraphicView: CameraGraphicView,
        previewLayer: AVCaptureVideoPreviewLayer
    ) {                
        self.cameraGraphicView = cameraGraphicView
        self.previewLayer = previewLayer
    }
            
    public func getError(boundingBox: CGRect) -> String? {
                
        let screenWidth = self.previewLayer.bounds.width
        let screenHeight = self.previewLayer.bounds.height
                           
        // Face is out of the screen.
        let isOutOfTheScreen =
            boundingBox.minX < 0 ||
            boundingBox.minY < 0 ||
            boundingBox.maxY > screenHeight ||
            boundingBox.maxX > screenWidth
        if isOutOfTheScreen {
            return ""
        }
        
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let boundingBoxRelatedWithScreen = Float(boundingBox.width / screenWidth)

        // Face smaller than the capture minimum size.
        if (boundingBoxRelatedWithScreen < captureOptions.faceCaptureMinSize) {
            return Message.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue
        }
        
        // Face bigger than the capture maximum size.
        if (boundingBoxRelatedWithScreen > captureOptions.faceCaptureMaxSize) {
            return Message.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue
        }
        
        if captureOptions.faceROI.enable {
            
            // Detection box offsets.
            let topOffset = CGFloat(boundingBox.minY / screenHeight)
            let rightOffset = CGFloat((screenWidth - boundingBox.maxX) / screenWidth)
            let bottomOffset = CGFloat((screenHeight - boundingBox.maxY) / screenHeight)
            let leftOffset = CGFloat(boundingBox.minX / screenWidth)
            
            if captureOptions.faceROI.isOutOf(
                topOffset: topOffset,
                rightOffset: rightOffset,
                bottomOffset: bottomOffset,
                leftOffset: leftOffset
            ) {
                return Message.INVALID_CAPTURE_FACE_OUT_OF_ROI.rawValue
            }
            
            if captureOptions.faceROI.hasChanges {
                
                // Face is inside the region of interest and faceROI is setted.
                // Face is smaller than the defined "minimumSize".
                let roiWidth: Float =
                    Float(screenWidth) -
                    (Float(captureOptions.faceROI.rightOffset + captureOptions.faceROI.leftOffset) *
                        Float(screenWidth))
                
                let faceRelatedWithROI: Float = Float(boundingBox.width) / roiWidth
                                                    
                if captureOptions.faceROI.minimumSize > faceRelatedWithROI {
                    return Message.INVALID_CAPTURE_FACE_ROI_MIN_SIZE.rawValue
                }
            }
        }
        
        return nil
    }
}
