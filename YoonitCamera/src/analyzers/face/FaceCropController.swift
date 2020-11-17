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


import Foundation
import Accelerate
import UIKit
import VideoToolbox
import AVFoundation
import Vision

class FaceCropController {
        
    func cropImage(
        image: CGImage,
        boundingBox: CGRect,
        captureOptions: CaptureOptions,
        completion: @escaping (UIImage) -> Void)
    {
        let faceDetectRequest = VNDetectFaceRectanglesRequest {
            request, error in

            if error != nil {
                return
            }

            if let results =
                request.results as? [VNFaceObservation],
               results.count > 0 {
                
                let closestFace = results.sorted {
                    return $0.boundingBox.width > $1.boundingBox.width
                    }[0]
                
                let imageCropped = self.crop(
                    boundingBox: closestFace
                        .boundingBox
                        .increase(by: CGFloat(captureOptions.facePaddingPercent)),
                    image: image)
                                                
                if (captureOptions.cameraLens.rawValue == 1) {
                    completion(imageCropped)
                } else {
                    completion(imageCropped.withHorizontallyFlippedOrientation())
                }
            }
        }

        try? VNImageRequestHandler(cgImage: image, options: [:]).perform([faceDetectRequest])
    }
                            
    private func crop(boundingBox: CGRect, image: CGImage) -> UIImage {
        let width = boundingBox.width * CGFloat(image.width)
        let height = boundingBox.height * CGFloat(image.height)
        let x = boundingBox.origin.x * CGFloat(image.width)
        let y = (1 - boundingBox.origin.y) * CGFloat(image.height) - height
        
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        return UIImage(cgImage: image.cropping(to: croppingRect)!)
    }
}
