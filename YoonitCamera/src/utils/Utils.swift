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
import AVFoundation
import Accelerate

func imageFromPixelBuffer(
    imageBuffer: CVPixelBuffer,
    scale: CGFloat,
    orientation: UIImage.Orientation) -> UIImage {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
    
    // Get the number of bytes per row for the pixel buffer
    let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
    
    // Get the number of bytes per row for the pixel buffer
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    
    // Get the pixel buffer width and height
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    
    // Create a device-dependent RGB color space
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // Create a bitmap graphics context with the sample buffer data
    var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
    bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    
    //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
    let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    let quartzImage = context?.makeImage()
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
    
    // Create an image object from the Quartz image
    let image = UIImage.init(cgImage: quartzImage!,
                             scale: scale,
                             orientation: orientation)
    
    return image
}


func getYcpCbCrFullRange() -> vImage_YpCbCrPixelRange {
    return vImage_YpCbCrPixelRange(Yp_bias: 0,
                                   CbCr_bias: 128,
                                   YpRangeMax: 255,
                                   CbCrRangeMax: 255,
                                   YpMax: 255,
                                   YpMin: 1,
                                   CbCrMax: 255,
                                   CbCrMin: 1)
}

let redCoefficient: Float = 0.2126
let greenCoefficient: Float = 0.7152
let blueCoefficient: Float = 0.0722

let divisor: Int32 = 0x1000
let fDivisor = Float(divisor)

var coefficientsMatrix = [
    Int16(redCoefficient * fDivisor),
    Int16(greenCoefficient * fDivisor),
    Int16(blueCoefficient * fDivisor)
]

let preBias: [Int16] = [0, 0, 0, 0]
let postBias: Int32 = 0

func convertToGrayScale(_ pixelBuffer: CVPixelBuffer) -> vImage_Buffer {
    
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    
    let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
    
    var sourceBuffer = vImage_Buffer(data: baseAddress!,
                                     height: vImagePixelCount(height),
                                     width: vImagePixelCount(width),
                                     rowBytes: rowBytes)
    
    let lumaData = UnsafeMutablePointer<Pixel_8>.allocate(capacity: width*height)
    var destinationBuffer = vImage_Buffer(data: lumaData,
                                          height: vImagePixelCount(height),
                                          width: vImagePixelCount(width),
                                          rowBytes: width)
    
    vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                           &destinationBuffer,
                                           &coefficientsMatrix,
                                           divisor,
                                           preBias,
                                           postBias,
                                           vImage_Flags(kvImageNoFlags))
    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    
    return destinationBuffer
}
