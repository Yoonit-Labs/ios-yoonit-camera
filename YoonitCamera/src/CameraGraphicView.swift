//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya @ Cyberlabs AI 2020                              |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//

import Foundation
import UIKit

/**
 This view is responsible to draw:
 
 - face detection box;
 - face blur;
 - face contours;
 */
public class CameraGraphicView: UIView {
        
    // The face detection box.
    private var faceDetectionBox: CGRect? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isOpaque = false
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw face detection box.
        if captureOptions.faceDetectionBox {
            self.drawFaceDetectionBox(context: context)
        }
    }
    
    /**
     Draw face bitmap blurred above the face detection box.
     
     - Parameter faceDetectionBox The face coordinates within the UI graphic view.
     */
    func handleDraw(faceDetectionBox: CGRect) {
        self.faceDetectionBox = faceDetectionBox
        
        self.setNeedsDisplay()
    }
    
    /**
     Erase anything draw.
     */
    func clear() {
        self.faceDetectionBox = nil
        
        self.setNeedsDisplay()
    }
    
    /**
     Draw the face detection box.
     
     - Parameter context The UI graphic view context.
     */
    func drawFaceDetectionBox(context: CGContext) {
        if let faceDetectionBox = self.faceDetectionBox {
            context.setLineWidth(2)
            context.setStrokeColor(UIColor.white.cgColor)
            context.stroke(faceDetectionBox)
            
            let left = faceDetectionBox.minX
            let top = faceDetectionBox.minY
            let right = faceDetectionBox.maxX
            let bottom = faceDetectionBox.maxY
            let midY = (bottom - top) / 2.0
            
            // edge - top-left > bottom-left
            self.drawLine(
                context: context,
                from: CGPoint(x: left, y: top),
                to: CGPoint(x: left, y: bottom - (midY * 1.5))
            )
                                
            // edge - top-right > bottom-right
            drawLine(
                context: context,
                from: CGPoint(x: right, y: top),
                to: CGPoint(x: right, y: bottom - (midY * 1.5))
            )
            
            // edge - bottom-left > top-left
            drawLine(
                context: context,
                from: CGPoint(x: left, y: bottom),
                to: CGPoint(x: left, y: bottom - (midY * 0.5))
            )

            // edge - bottom-right > top-right
            drawLine(
                context: context,
                from: CGPoint(x: right, y: bottom),
                to: CGPoint(x: right, y: bottom - (midY * 0.5))
            )

            // edge - top-left > top-right
            drawLine(
                context: context,
                from: CGPoint(x: left, y: top),
                to: CGPoint(x: left + (midY * 0.5), y: top)
            )

            // edge - top-right > left-right
            drawLine(
                context: context,
                from: CGPoint(x: right, y: top),
                to: CGPoint(x: right - (midY * 0.5), y: top)
            )

            // edge - bottom-left > right-left
            drawLine(
                context: context,
                from: CGPoint(x: left, y: bottom),
                to: CGPoint(x: left + (midY * 0.5), y: bottom)
            )

            // edge - bottom-right > right-left
            drawLine(
                context: context,
                from: CGPoint(x: right, y: bottom),
                to: CGPoint(x: right - (midY * 0.5), y: bottom)
            )
        }
    }
                
    func drawLine(
        context: CGContext,
        from: CGPoint,
        to: CGPoint
    ) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(6)
        context.setLineCap(.round)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
    }
}
