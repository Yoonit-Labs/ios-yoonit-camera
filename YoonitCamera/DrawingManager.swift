//
//  DrawingManager.swift
//  YoonitCamera
//
//  Created by Hallison da Paz on 08/03/20.
//

import Foundation
import UIKit

class DrawingManager {
    
    func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint) {
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
       line.lineCap = CAShapeLayerLineCap.round // this parameter solve my problem
       layer.addSublayer(line)
    }
    
    func makeShapeFor(_ boundingBox: CGRect) -> [CAShapeLayer] {
        var drawings: [CAShapeLayer] = []
            
        let faceBoundingBoxPath = CGPath(rect: boundingBox, transform: nil)
        let faceBoundingBoxShape = CAShapeLayer()
        faceBoundingBoxShape.path = faceBoundingBoxPath
        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
        faceBoundingBoxShape.strokeColor = UIColor.white.cgColor
        faceBoundingBoxShape.lineWidth = 2
    
        let x = boundingBox.midX
        let y = boundingBox.midY

        // Draws a bounding box around the face.
        let xOffset = (boundingBox.width / 2.0)
        let yOffset = (boundingBox.height / 2.0)

        let left = x - xOffset
        let top = y - yOffset
        let right = x + xOffset
        let bottom = y + yOffset

        // edge - top-left > bottom-left
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: left, y: bottom - (yOffset * 1.5)))

        // edge - top-right > bottom-right
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: right, y: top), toPoint: CGPoint(x: right, y: bottom - (yOffset * 1.5)))
        
        // edge - bottom-left > top-left
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: left, y: bottom), toPoint: CGPoint(x: left, y: bottom - (yOffset * 0.5)))

        // edge - bottom-right > top-right
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: right, y: bottom), toPoint: CGPoint(x: right, y: bottom - (yOffset * 0.5)))

        // edge - top-left > top-right
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: left + (yOffset * 0.5), y: top))

        // edge - top-right > left-right
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: right, y: top), toPoint: CGPoint(x: right - (yOffset * 0.5), y: top))

        // edge - bottom-left > right-left
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: left, y: bottom), toPoint: CGPoint(x: left + (yOffset * 0.5), y: bottom))

        // edge - bottom-right > right-left
        drawLine(onLayer: faceBoundingBoxShape, fromPoint: CGPoint(x: right, y: bottom), toPoint: CGPoint(x: right - (yOffset * 0.5), y: bottom))
        
        drawings.append(faceBoundingBoxShape)
        
        return drawings
    }
}
