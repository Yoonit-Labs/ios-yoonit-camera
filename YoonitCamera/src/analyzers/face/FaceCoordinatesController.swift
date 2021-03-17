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

class FaceCoordinatesController {
        
    private var cameraGraphicView: CameraGraphicView
        
    init(cameraGraphicView: CameraGraphicView) {
        self.cameraGraphicView = cameraGraphicView
    }
            
    public func hasFaceDetectionBoxError(faceDetectionBox: CGRect?) -> String? {
                
        guard let faceDetectionBox: CGRect = faceDetectionBox else {
            return ""
        }
        
        let screenWidth = self.cameraGraphicView.bounds.width
        let screenHeight = self.cameraGraphicView.bounds.height
                           
        // Face is out of the screen.
        let isOutOfTheScreen =
            faceDetectionBox.minX < 0 ||
            faceDetectionBox.minY < 0 ||
            faceDetectionBox.maxY > screenHeight ||
            faceDetectionBox.maxX > screenWidth
        if isOutOfTheScreen {
            return ""
        }
        
        // This variable is the face detection box percentage in relation with the
        // UI view. The value must be between 0 and 1.
        let faceDetectionBoxRelatedWithScreen = Float(faceDetectionBox.width / screenWidth)

        // Face smaller than the capture minimum size.
        if (faceDetectionBoxRelatedWithScreen < captureOptions.faceCaptureMinSize) {
            return Message.INVALID_CAPTURE_FACE_MIN_SIZE.rawValue
        }
        
        // Face bigger than the capture maximum size.
        if (faceDetectionBoxRelatedWithScreen > captureOptions.faceCaptureMaxSize) {
            return Message.INVALID_CAPTURE_FACE_MAX_SIZE.rawValue
        }
        
        if captureOptions.faceROI.enable {
            
            // Detection box offsets.
            let topOffset = CGFloat(faceDetectionBox.minY / screenHeight)
            let rightOffset = CGFloat((screenWidth - faceDetectionBox.maxX) / screenWidth)
            let bottomOffset = CGFloat((screenHeight - faceDetectionBox.maxY) / screenHeight)
            let leftOffset = CGFloat(faceDetectionBox.minX / screenWidth)
            
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
                
                let faceRelatedWithROI: Float = Float(faceDetectionBox.width) / roiWidth
                                                    
                if captureOptions.faceROI.minimumSize > faceRelatedWithROI {
                    return Message.INVALID_CAPTURE_FACE_ROI_MIN_SIZE.rawValue
                }
            }
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
        let viewWidth: CGFloat = self.cameraGraphicView.frame.width
        var faceContours: [CGPoint] = []
        
        for point in contours {
            let scaledXY: CGPoint = self.getScale(
                imageWidth: CGFloat(cgImage.width),
                imageHeight: CGFloat(cgImage.height)
            )
            var x: CGFloat = point.x * scaledXY.x
            if captureOptions.cameraLens == AVCaptureDevice.Position.front {
                x = viewWidth - x
            }
            let y: CGFloat = point.y * scaledXY.y
            faceContours.append(CGPoint(x: x, y: y))
        }
        
        return faceContours
    }
        
    public func getDetectionBox(
        cameraInputImage: UIImage,
        faceDetected: FaceDetected?
    ) -> CGRect? {
        guard let cgImage: CGImage = cameraInputImage.cgImage else {
            return nil
        }

        guard let faceDetected: FaceDetected = faceDetected else {
            return nil
        }

        let viewWidth: CGFloat = self.cameraGraphicView.frame.width
        let scaledXY: CGPoint = self.getScale(
            imageWidth: CGFloat(cgImage.width),
            imageHeight: CGFloat(cgImage.height)
        )

        let top: CGFloat = faceDetected.boundingBox.minY * scaledXY.y
        var right: CGFloat = faceDetected.boundingBox.maxX * scaledXY.x
        if captureOptions.cameraLens == AVCaptureDevice.Position.front {
            right = viewWidth - right
        }
        let bottom: CGFloat = faceDetected.boundingBox.maxY * scaledXY.y
        var left: CGFloat = faceDetected.boundingBox.minX * scaledXY.x
        if captureOptions.cameraLens == AVCaptureDevice.Position.front {
            left = viewWidth - left
        }

        return CGRect(
            x: left,
            y: top,
            width: right - left,
            height: bottom - top
        )
    }
    
    private func getScale(
        imageWidth: CGFloat,
        imageHeight: CGFloat
    ) -> CGPoint {
        let viewWidth: CGFloat = self.cameraGraphicView.frame.width
        let viewHeight: CGFloat = self.cameraGraphicView.frame.height
        var scaleX: CGFloat
        var scaleY: CGFloat
        
        scaleX = viewHeight / imageHeight
        scaleY = viewWidth / imageWidth
        
        return CGPoint(x: scaleX, y: scaleY)
    }
}
