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
         
    private let topSafeHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            return safeFrame.minY > 24 ? safeFrame.minY : 0
        } else {
            return 0
        }
    }()
    
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
    
    public func getDetectionBox(
        boundingBox: CGRect,
        imageBuffer: CVPixelBuffer
    ) -> CGRect {
        let faceBoundingBox = previewLayer
            .layerRectConverted(fromMetadataOutputRect: boundingBox)
            .increase(by: CGFloat(captureOptions.facePaddingPercent))
        
        if faceBoundingBox.isNaN() {
            return CGRect()
        }
        
        let scale = CGFloat(CVPixelBufferGetWidth(imageBuffer)) / self.cameraGraphicView.bounds.width
        let faceBoundingBoxScaled = faceBoundingBox.adjustedBySafeArea(height: self.topSafeHeight / scale)
        
        let left = Int(faceBoundingBoxScaled.minX)
        let top = Int(faceBoundingBoxScaled.minY)
        let right = Int(faceBoundingBoxScaled.maxX)
        let bottom = Int(faceBoundingBoxScaled.maxY)
            
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
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
    ) -> CGRect {
        guard let cgImage: CGImage = cameraInputImage.cgImage else {
            return CGRect()
        }

        guard let faceDetected: FaceDetected = faceDetected else {
            return CGRect()
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
