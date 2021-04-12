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
import Vision

extension CVPixelBuffer {
    func toUIImage() -> UIImage {
        let ciImage: CIImage = CIImage(cvPixelBuffer: self)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image: UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension CGRect {
    func scale(by percentage: CGFloat) -> CGRect {
        let adjustmentWidth = (self.width * percentage) / 2.0
        let adjustmentHeight = (self.height * percentage) / 2.0
        return self.insetBy(dx: -adjustmentWidth, dy: -adjustmentHeight)
    }
    
    func isNaN() -> Bool {
        return self.minY.isNaN || self.maxY.isNaN || self.minX.isNaN || self.maxX.isNaN
    }
}

extension UIImage {
    
    func resize(width: Int, height: Int) throws -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        let newSize = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        self.draw(in: newSize)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width, y: self.size.height)
        context.scaleBy(x: -self.scale, y: -self.scale)
        context.draw(self.cgImage!, in: CGRect(origin:CGPoint.zero, size: self.size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }
}
