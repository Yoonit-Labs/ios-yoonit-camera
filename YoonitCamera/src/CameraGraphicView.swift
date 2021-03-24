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
    
    private var detectionBox: CGRect? = nil
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
            captureOptions.roi.enable &&
            captureOptions.roi.areaOffsetEnable
        if isDrawFaceROIAreaOffset {
            self.drawFaceROIAreaOffset(context: context, rect: rect)
        }
        
        // Draw face detection box.
        let isDrawDetectionBox: Bool =
            captureOptions.detectionBox &&
            self.detectionBox != nil
        if isDrawDetectionBox {
            self.drawDetectionBox(context: context)
        }
                
        // Draw face contours.
        if !self.faceContours.isEmpty && captureOptions.faceContours {
            self.drawFaceContours(context: context)
        }
    }
        
    public func handleDraw(
        detectionBox: CGRect,
        faceContours: [CGPoint]
    ) {
        self.detectionBox = detectionBox
        self.faceContours = faceContours
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
        
    public func handleDraw(detectionBox: CGRect) {
        self.detectionBox = detectionBox
        self.faceContours = []
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
        
    public func clear() {
        self.detectionBox = nil
        self.faceContours = []

        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func drawFaceROIAreaOffset(context: CGContext, rect: CGRect) {
        let topOffset: CGFloat = rect.height * captureOptions.roi.topOffset
        let rightOffset: CGFloat = rect.width * captureOptions.roi.rightOffset
        let bottomOffset: CGFloat = rect.height * captureOptions.roi.bottomOffset
        let leftOffset: CGFloat = rect.width * captureOptions.roi.leftOffset
        
        let smallRect: CGRect = CGRect(
            x: leftOffset,
            y: topOffset,
            width: rect.width - (rightOffset + leftOffset),
            height: rect.height - (topOffset + bottomOffset)
        )
        
        context.setFillColor(captureOptions.roi.areaOffsetColor.cgColor)
        context.fill(rect)
        context.clear(smallRect)
    }
            
    func drawDetectionBox(context: CGContext) {
        guard let detectionBox: CGRect = self.detectionBox else {
            return
        }
        
        context.setLineWidth(2)
        context.setStrokeColor(UIColor.white.cgColor)
        context.stroke(detectionBox)
        
        let left = detectionBox.minX
        let top = detectionBox.minY
        let right = detectionBox.maxX
        let bottom = detectionBox.maxY
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
