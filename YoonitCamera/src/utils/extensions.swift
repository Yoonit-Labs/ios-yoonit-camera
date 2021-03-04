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

extension CVPixelBuffer {
    func toUIImage(orientation: AVCaptureDevice.Position) -> UIImage {
        let ciImage: CIImage = CIImage(cvPixelBuffer: self)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image: UIImage = UIImage.init(cgImage: cgImage)
        
//        if orientation == AVCaptureDevice.Position.back {
//            return image
//        }
        
        return image.withHorizontallyFlippedOrientation()
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension CGRect {
    func adjustedBySafeArea(height: CGFloat) -> CGRect {
        return height < 0.1 ? self : CGRect(
            x: self.minX,
            y: self.minY - height,
            width: self.width,
            height: self.height)
    }
    
    func increase(by percentage: CGFloat) -> CGRect {
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
            height: height)
        
        self.draw(in: newSize)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage!
    }
}
