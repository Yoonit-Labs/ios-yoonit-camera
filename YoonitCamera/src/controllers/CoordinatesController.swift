//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya & Marcio Brufatto @ Cyberlabs AI 2020-2021       |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//

import AVFoundation
import UIKit
import YoonitFacefy
import Vision

/**
 Responsible to manipulate everything related with the UI coordinates.
 */
class CoordinatesController {
        
    private var cameraGraphicView: CameraGraphicView
             
    init(cameraGraphicView: CameraGraphicView) {
        self.cameraGraphicView = cameraGraphicView
    }
            
    public func hasFaceDetectionBoxError(detectionBox: CGRect) -> String? {
                            
        if detectionBox.isEmpty {
            return ""
        }
        
        let screenWidth = self.cameraGraphicView.bounds.width
        let screenHeight = self.cameraGraphicView.bounds.height
                           
        // Face is out of the screen.
        let isOutOfTheScreen =
            detectionBox.minX < 0 ||
            detectionBox.minY < 0 ||
            detectionBox.maxY > screenHeight ||
            detectionBox.maxX > screenWidth
        if isOutOfTheScreen {
            return ""
        }
                
        if captureOptions.roi.enable {
            
            // Detection box offsets.
            let topOffset = CGFloat(detectionBox.minY / screenHeight)
            let rightOffset = CGFloat((screenWidth - detectionBox.maxX) / screenWidth)
            let bottomOffset = CGFloat((screenHeight - detectionBox.maxY) / screenHeight)
            let leftOffset = CGFloat(detectionBox.minX / screenWidth)
            
            if captureOptions.roi.isOutOf(
                topOffset: topOffset,
                rightOffset: rightOffset,
                bottomOffset: bottomOffset,
                leftOffset: leftOffset
            ) {
                return Message.INVALID_OUT_OF_ROI.rawValue
            }
            
            if captureOptions.roi.hasChanges {
                
                // Face is inside the region of interest and faceROI is setted.
                // Face is smaller than the defined "minimumSize".
                let roiWidth: Float =
                    Float(screenWidth) -
                    (Float(captureOptions.roi.rightOffset + captureOptions.roi.leftOffset) *
                        Float(screenWidth))
                
                let faceRelatedWithROI: Float = Float(detectionBox.width) / roiWidth
                                           
                if captureOptions.minimumSize > faceRelatedWithROI {
                    return Message.INVALID_MINIMUM_SIZE.rawValue
                }
            }
            
            return nil
        }
        
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let detectionBoxRelatedWithScreen = Float(detectionBox.width / screenWidth)
        
        // Face smaller than the capture minimum size.
        if (detectionBoxRelatedWithScreen < captureOptions.minimumSize) {
            return Message.INVALID_MINIMUM_SIZE.rawValue
        }
        
        // Face bigger than the capture maximum size.
        if (detectionBoxRelatedWithScreen > captureOptions.maximumSize) {
            return Message.INVALID_MAXIMUM_SIZE.rawValue
        }
        
        return nil
    }
        
    public func getFaceContours(
        cameraInputImage: UIImage,
        contours: [CGPoint]
    ) -> [CGPoint] {
        guard let cgImage: CGImage = cameraInputImage.cgImage else {
            return []
        }
        
        var faceContours: [CGPoint] = []
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        for point in contours {
            let normalizedPoint: CGPoint = CGPoint(
                x: point.y / imageHeight,
                y: point.x / imageWidth
            )
            let standardizedPoint: CGPoint = previewLayer
                .layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
            faceContours.append(standardizedPoint)
        }
        
        return faceContours
    }
            
    public func getDetectionBox(
        cameraInputImage: UIImage,
        faceDetected: FaceDetected?
    ) -> CGRect {
        guard let cgImage: CGImage = cameraInputImage.cgImage else {
            return CGRect()
        }

        guard let faceDetected: FaceDetected = faceDetected else {
            return CGRect()
        }
              
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        let normalizedRect = CGRect(
            x: CGFloat(faceDetected.boundingBox.origin.y) / imageHeight,
            y: CGFloat(faceDetected.boundingBox.origin.x) / imageWidth,
            width: CGFloat(faceDetected.boundingBox.size.height) / imageHeight,
            height: CGFloat(faceDetected.boundingBox.size.width) / imageWidth
        )
        let standardizedRect = previewLayer
            .layerRectConverted(fromMetadataOutputRect: normalizedRect)
            .standardized
                   
        if standardizedRect.isNaN() {
            return CGRect()
        }
                
        return standardizedRect
    }
}
