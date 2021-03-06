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
 - face contours;
 */
public class CameraGraphicView: UIView {
        
    public var draw: Bool = false {
        didSet {
            if !self.draw {
                self.clear()
            }
        }
    }
    
    private var faceDetectionBox: CGRect? = nil
    private var faceContours: [CGPoint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isOpaque = false
    }
    
    public override func draw(_ rect: CGRect) {
        if !self.draw {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw face region of interest area offset bitmap.
        let isDrawFaceROIAreaOffset: Bool =
            captureOptions.faceROI.enable &&
            captureOptions.faceROI.areaOffsetEnable
        if isDrawFaceROIAreaOffset {
            self.drawFaceROIAreaOffset(context: context, rect: rect)
        }
        
        // Draw face detection box.
        let isDrawFaceDetectionBox: Bool =
            captureOptions.faceDetectionBox &&
            self.faceDetectionBox != nil
        if isDrawFaceDetectionBox {
            self.drawFaceDetectionBox(context: context)
        }
                
        // Draw face contours.
        if !self.faceContours.isEmpty && captureOptions.faceContours {
            self.drawFaceContours(context: context)
        }
    }
    
    /**
     Draw face bitmap blurred above the face detection box.
          
     - Parameter faceDetectionBox: The face coordinates within the UI graphic view.
     - Parameter faceContours: List of points that represents the shape of the face detected .
     */
    func handleDraw(
        faceDetectionBox: CGRect,
        faceContours: [CGPoint]
    ) {
        self.faceDetectionBox = faceDetectionBox
        self.faceContours = faceContours
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    /**
     Erase anything draw.
     */
    func clear() {
        self.faceDetectionBox = nil
        self.faceContours = []

        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func drawFaceROIAreaOffset(context: CGContext, rect: CGRect) {
        let topOffset: CGFloat = rect.height * captureOptions.faceROI.topOffset
        let rightOffset: CGFloat = rect.width * captureOptions.faceROI.rightOffset
        let bottomOffset: CGFloat = rect.height * captureOptions.faceROI.bottomOffset
        let leftOffset: CGFloat = rect.width * captureOptions.faceROI.leftOffset
        
        let smallRect: CGRect = CGRect(
            x: leftOffset,
            y: topOffset,
            width: rect.width - (rightOffset + leftOffset),
            height: rect.height - (topOffset + bottomOffset)
        )
        
        context.setFillColor(captureOptions.faceROI.areaOffsetColor.cgColor)
        context.fill(rect)
        context.clear(smallRect)
    }
            
    func drawFaceDetectionBox(context: CGContext) {
        guard let faceDetectionBox: CGRect = self.faceDetectionBox else {
            return
        }
        
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
        self.drawLine(
            context: context,
            from: CGPoint(x: right, y: top),
            to: CGPoint(x: right, y: bottom - (midY * 1.5))
        )
        
        // edge - bottom-left > top-left
        self.drawLine(
            context: context,
            from: CGPoint(x: left, y: bottom),
            to: CGPoint(x: left, y: bottom - (midY * 0.5))
        )

        // edge - bottom-right > top-right
        self.drawLine(
            context: context,
            from: CGPoint(x: right, y: bottom),
            to: CGPoint(x: right, y: bottom - (midY * 0.5))
        )

        // edge - top-left > top-right
        self.drawLine(
            context: context,
            from: CGPoint(x: left, y: top),
            to: CGPoint(x: left + (midY * 0.5), y: top)
        )

        // edge - top-right > left-right
        self.drawLine(
            context: context,
            from: CGPoint(x: right, y: top),
            to: CGPoint(x: right - (midY * 0.5), y: top)
        )

        // edge - bottom-left > right-left
        self.drawLine(
            context: context,
            from: CGPoint(x: left, y: bottom),
            to: CGPoint(x: left + (midY * 0.5), y: bottom)
        )

        // edge - bottom-right > right-left
        self.drawLine(
            context: context,
            from: CGPoint(x: right, y: bottom),
            to: CGPoint(x: right - (midY * 0.5), y: bottom)
        )
    }
    
    func drawFaceContours(context: CGContext) {
        let size = CGSize(width: 4, height: 4)
        captureOptions.faceContoursColor.set()
        
        for point in self.faceContours {
            let dot: CGRect = CGRect(
                origin: CGPoint(x: point.x, y: point.y),
                size: size
            )
            let dotPath = UIBezierPath(ovalIn: dot)
            dotPath.fill()
        }
    }
    
    private func drawLine(
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
