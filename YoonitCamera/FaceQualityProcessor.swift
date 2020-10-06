//
//  FaceQualityProcessor.swift
//  FaceTracker
//
//  Created by Hallison da Paz on 04/03/20.
//

import Foundation
import Accelerate
import UIKit
import VideoToolbox

class FaceQualityProcessor {
    
    let DARKNESS_THRESHOLD = 0.4
    let LIGHTNESS_THRESHOLD = 0.65
    var statusBarHeight: CGFloat = 0.0
    var laplacianKernel: [Int16] = [-1, -1, -1,
                                    -1,  8, -1,
                                    -1, -1, -1]
    
    lazy var lapDivisor = laplacianKernel.map { Int32($0) }.reduce(0, +)
    
    private var imageIndex = 0
    private let queue = DispatchQueue(label: "ai.cyberlabs.imageprocessing", qos: .userInitiated)
    
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
        view: FaceAnalyzer) {
                
        // Grayscale version.
        var lumaBuffer = convertToGrayScale(pixels)
                                
        // Classify ilumination.
        let hasGoodIlumination = self.evaluateIluminationFor(lumaImageBuffer: &lumaBuffer)
        
        if (hasGoodIlumination) {
            // Classify image quality.
            let imageQuality = self.computeFaceQuality(lumaImageBuffer: &lumaBuffer)
                            
            // Convert CVPixelBuffer to UIImage.
            let image = imageFromPixelBuffer(imageBuffer: pixels, scale: UIScreen.main.scale)
            
            // Crop the face and scale.
            guard let imageCropped = self.crop(imageCamera: image, boundingBoxFace: faceRect) else {
                return
            }
                
            self.imageIndex = view.numCapturedImages
            let fileURL = fileURLFor(index: self.imageIndex)
            let fileName = try! save(image: imageCropped, at: fileURL)
            
            DispatchQueue.main.async {
                view.notifyCapturedImage(filePath: fileName)
            }
        }
    }
    
    
    func computeFaceQuality(lumaImageBuffer: inout vImage_Buffer) -> Float {
//        TODO: contrast reserved for future use
//        let contrast = Float.random(in: 0.0...1.0)
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
        
    func evaluateIluminationFor(lumaImageBuffer: inout vImage_Buffer) -> Bool{
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

        error = vImageConvolve_Planar8(&lumaImageBuffer,
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
            print("XABU NA CONVOLUCAO - linha 216")
        }

        let count = destinationBuffer.width * destinationBuffer.height
        let arr = UnsafeMutableBufferPointer(start: destinationBuffer.data.assumingMemoryBound(to: UInt8.self),
                                             count: Int(count))

        var doubleArr = [Double](repeating: 0.0, count: Int(count))
        vDSP_vfltu8D(UnsafePointer<UInt8>(arr.baseAddress!), 1, &doubleArr, 1, count)

        // TODO: deal with Nan
        print(doubleArr.filter({$0 < 0}))
        var avg = 0.0
        var std = 0.0
        vDSP_normalizeD(doubleArr,
                        1,
                        nil,
                        1,
                        &avg,
                        &std,
                        UInt(doubleArr.count))

        return Float(std)
    }
}
