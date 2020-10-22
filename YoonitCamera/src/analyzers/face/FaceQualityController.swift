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

class FaceQualityController {
    
    private let DARKNESS_THRESHOLD = 0.4
    private let LIGHTNESS_THRESHOLD = 0.65
    private var statusBarHeight: CGFloat = 0.0
    private var laplacianKernel: [Int16] = [-1, -1, -1,
                                    -1,  8, -1,
                                    -1, -1, -1]
    
    private lazy var lapDivisor = laplacianKernel.map { Int32($0) }.reduce(0, +)
    
    init() {
        DispatchQueue.main.async {
            var hasNotch: Bool {
                let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                return bottom > 0
            }

            if (hasNotch) {
                self.statusBarHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            } else {
                self.statusBarHeight = UIApplication.shared.statusBarFrame.size.height * -1
            }
        }
    }
            
    func process(
        pixels: CVPixelBuffer,
        toRect faceRect: CGRect,
        atScale scale: CGFloat,
        captureOptions: CaptureOptions,
        faceAnalyzer: FaceAnalyzer) {
                                
        // Grayscale version.
        var lumaBuffer = convertToGrayScale(pixels)
                                
        // Classify ilumination.
        let hasGoodIlumination = self.evaluateIluminationFor(lumaImageBuffer: &lumaBuffer)
        
        if (hasGoodIlumination) {
            // Classify image quality.
            let imageQuality = self.computeFaceQuality(lumaImageBuffer: &lumaBuffer)
            
            //set the orientation of the image
            let orientation = captureOptions.cameraLensFacing.rawValue == 1 ? UIImage.Orientation.up : UIImage.Orientation.upMirrored
            
            // Convert CVPixelBuffer to UIImage.
            let image = imageFromPixelBuffer(imageBuffer: pixels, scale: UIScreen.main.scale, orientation: orientation)

            // Crop the face and scale.
            let imageCropped = self.crop(imageCamera: image, boundingBoxFace: faceRect)
            
            // The image cropped can be null because the bounding box must be inside the screen.
            if (imageCropped == nil) {
                return
            }
                        
            // Resize image based in the capture options.
            let imageResized = try! imageCropped!.resized(to: captureOptions.faceImageSize)
            
            let fileURL = fileURLFor(index: faceAnalyzer.numberOfImages)
            let fileName = try! save(image: imageResized, at: fileURL)
                        
            faceAnalyzer.notifyCapturedImage(filePath: fileName)
        }
    }
    
    
    func computeFaceQuality(lumaImageBuffer: inout vImage_Buffer) -> Float {
        let sharpness = evaluateSharpness(&lumaImageBuffer)
        return sharpness
    }
            
    func crop(imageCamera: UIImage, boundingBoxFace: CGRect) -> UIImage? {

        let ratio = min(
            UIScreen.main.bounds.size.width / imageCamera.size.width,
            UIScreen.main.bounds.size.height / imageCamera.size.height);
        let image = try! imageCamera.resized(to: CGSize(
            width: imageCamera.size.width * ratio,
            height: imageCamera.size.height * ratio))
        let origin = CGPoint(
            x: boundingBoxFace.origin.x * -1.0,
            y: boundingBoxFace.origin.y * -1.0 + self.statusBarHeight)

        if (origin.x * -1 < 0) {
            return nil
        }
        if (origin.y * -1 < 0) {
            return nil
        }
        if (UIScreen.main.bounds.width < origin.x * -1 + boundingBoxFace.size.width) {
            return nil
        }
        if (UIScreen.main.bounds.height < origin.y * -1 + boundingBoxFace.size.height) {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(boundingBoxFace.size, true, 0.0)
        image.draw(at: origin)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        if (result == nil) {
            return nil
        }
        UIGraphicsEndImageContext();
        return result
    }
        
    func evaluateIluminationFor(lumaImageBuffer: inout vImage_Buffer) -> Bool {
        let luma = [vImagePixelCount](repeating: 0, count: 256)
        let lumaHist = UnsafeMutablePointer<vImagePixelCount>(mutating: luma)
        var error = kvImageNoError
        
        error = vImageHistogramCalculation_Planar8(
                    &lumaImageBuffer,
                    lumaHist,
                    vImage_Flags(kvImagePrintDiagnosticsToConsole))
        if error != kvImageNoError {
            print("Histogram error: \(error)")
        }

        let count = Double(lumaImageBuffer.width * lumaImageBuffer.height)
        var dark = 0.0
        var light = 0.0
        
        for i in 0...35 {
            dark = dark + Double(lumaHist[i])
            light = light + Double(lumaHist[255-i])
        }
        dark = dark/count
        light = light/count
        
        if dark > DARKNESS_THRESHOLD || light > LIGHTNESS_THRESHOLD {
            return false
        }
        return true
    }
    
    func evaluateSharpness(_ lumaImageBuffer: inout vImage_Buffer) -> Float {

        var error = kvImageNoError
        var destinationBuffer = vImage_Buffer()
        error = kvImageNoError
        
        if destinationBuffer.data == nil {
            error = vImageBuffer_Init(
                &destinationBuffer,
                lumaImageBuffer.height,
                lumaImageBuffer.width,
                8,
                vImage_Flags(kvImageNoFlags))

            if (error != kvImageNoError) {
                print("Error unknow")
            }
        }

        defer {
            free(destinationBuffer.data)
        }

        error = vImageConvolve_Planar8(
            &lumaImageBuffer,
            &destinationBuffer,
            nil,
            0,
            0,
            &laplacianKernel,
            3,
            3,
            lapDivisor,
            0,
            vImage_Flags(kvImageEdgeExtend))
        
        if (error != kvImageNoError) {
            print("Error on convolution")
        }

        let count = destinationBuffer.width * destinationBuffer.height
        let arr = UnsafeMutableBufferPointer(start: destinationBuffer.data.assumingMemoryBound(to: UInt8.self), count: Int(count))
        var doubleArr = [Double](repeating: 0.0, count: Int(count))
        
        vDSP_vfltu8D(UnsafePointer<UInt8>(arr.baseAddress!), 1, &doubleArr, 1, count)
        
        var avg = 0.0
        var std = 0.0
        vDSP_normalizeD(
            doubleArr,
            1,
            nil,
            1,
            &avg,
            &std,
            UInt(doubleArr.count))

        return Float(std)
    }
}

