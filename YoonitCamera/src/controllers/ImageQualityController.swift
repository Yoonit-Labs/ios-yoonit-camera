//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya @ Cyberlabs AI 2021                              |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//

import Foundation
import UIKit
import Accelerate

/**
 This class is responsible to classifu the image quality by:
 - sharpness;
 - lightness;
 - darkness;
 */
class ImageQualityController {
    
    static let redCoefficient: Float = 0.2126
    static let greenCoefficient: Float = 0.7152
    static let blueCoefficient: Float = 0.0722
    static let divisor: Int32 = 0x1000
    
    static var coefficientsMatrix = [
        Int16(ImageQualityController.redCoefficient * Float(ImageQualityController.divisor)),
        Int16(ImageQualityController.greenCoefficient * Float(ImageQualityController.divisor)),
        Int16(ImageQualityController.blueCoefficient * Float(ImageQualityController.divisor))
    ]

    static let preBias: [Int16] = [0, 0, 0, 0]
    static let postBias: Int32 = 0
    
    static var laplacianKernel: [Int16] = [
        -1, -1, -1,
        -1,  8, -1,
        -1, -1, -1
    ]
    static var lapDivisor = ImageQualityController.laplacianKernel.map { Int32($0) }.reduce(0, +)
    
    /**
     Process the input image buffer.
     
     - Parameter imageBuffer: The camera frame input.
     
     - returns: tuple with the three values: darkness, lightness and sharpness.
     */
    static func processImage(imageBuffer: CVPixelBuffer) -> (NSNumber?, NSNumber?, NSNumber?) {
        
        // Gray scale version.
        var imageGrayBuffer = ImageQualityController
            .convertToGrayScale(imageBuffer: imageBuffer)
        
        // Classify ilumination.
        let (darkness, lightness) = ImageQualityController.classifyIlumination(imageBuffer: &imageGrayBuffer)
        
        // Classify sharpness.
        let sharpness = ImageQualityController.classifySharpness(imageBuffer: &imageGrayBuffer)
                                    
        return(
            darkness != nil ? NSNumber(value: darkness!) : nil,
            lightness != nil ? NSNumber(value: lightness!) : nil,
            sharpness != nil ? NSNumber(value: sharpness!) : nil
        )
    }

    /**
     Convert to gray scale image buffer.
     
     - Parameter imageBuffer: The camera frame input.
     */
    private static func convertToGrayScale(imageBuffer: CVPixelBuffer) -> vImage_Buffer {
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(imageBuffer)
        
        var sourceBuffer = vImage_Buffer(
            data: baseAddress!,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: rowBytes
        )
        
        let lumaData = UnsafeMutablePointer<Pixel_8>.allocate(capacity: width*height)
        
        var destinationBuffer = vImage_Buffer(
            data: lumaData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: width
        )
        
        vImageMatrixMultiply_ARGB8888ToPlanar8(
            &sourceBuffer,
            &destinationBuffer,
            &ImageQualityController.coefficientsMatrix,
            ImageQualityController.divisor,
            ImageQualityController.preBias,
            ImageQualityController.postBias,
            vImage_Flags(kvImageNoFlags)
        )
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        return destinationBuffer
    }
    
    /**
     Classify the input image buffer darkness and lightness.
     
     - Parameter imageBuffer: The camera frame input.
     */
    private static func classifyIlumination(imageBuffer: inout vImage_Buffer) -> (Double?, Double?) {
        let luma = [vImagePixelCount](repeating: 0, count: 256)
        let lumaHist = UnsafeMutablePointer<vImagePixelCount>(mutating: luma)
        
        var error = kvImageNoError
        error = vImageHistogramCalculation_Planar8(
            &imageBuffer,
            lumaHist,
            vImage_Flags(kvImagePrintDiagnosticsToConsole)
        )
        
        if error != kvImageNoError {
            return (nil, nil)
        }
                
        let count = Double(imageBuffer.width * imageBuffer.height)
        var darkness: Double = 0.0
        var lightness: Double = 0.0
        
        for i in 0...35 {
            darkness = darkness + Double(lumaHist[i])
            lightness = lightness + Double(lumaHist[255-i])
        }
        darkness = darkness / count
        lightness = lightness / count
        
        return (darkness, lightness)
    }
    
    /**
     Classify the input image buffer sharpness.
     
     - Parameter imageBuffer: The camera frame input.
     */
    private static func classifySharpness(imageBuffer: inout vImage_Buffer) -> Float? {
        
        var error = kvImageNoError
        var destinationBuffer = vImage_Buffer()
        
        if destinationBuffer.data == nil {
            error = vImageBuffer_Init(
                &destinationBuffer,
                imageBuffer.height,
                imageBuffer.width,
                8,
                vImage_Flags(kvImageNoFlags)
            )
            
            if (error != kvImageNoError) {
                return nil
            }
        }
        
        defer {
            free(destinationBuffer.data)
        }
        
        error = vImageConvolve_Planar8(
            &imageBuffer,
            &destinationBuffer,
            nil,
            0,
            0,
            &ImageQualityController.laplacianKernel,
            3,
            3,
            ImageQualityController.lapDivisor,
            0,
            vImage_Flags(kvImageEdgeExtend)
        )
        
        if (error != kvImageNoError) {
            return nil
        }
        
        let count = destinationBuffer.width * destinationBuffer.height
        let arr = UnsafeMutableBufferPointer(
            start: destinationBuffer.data.assumingMemoryBound(to: UInt8.self),
            count: Int(count)
        )
        
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
            UInt(doubleArr.count)
        )
        
        return Float(std)
    }
}
