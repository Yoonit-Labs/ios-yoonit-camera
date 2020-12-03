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
import UIKit

enum FileUtilsError: Error {
    case invalidJPEGData
}

func fileURLFor(index: Int) -> URL {
    let tempDirectory = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
    
    return tempDirectory.appendingPathComponent(String(format: "yoonit-%04d.jpg", index))
}

func save(image: UIImage, fileURL: URL) throws -> String {            
    let data = image.jpegData(compressionQuality: 1)
    
    if (data == nil) {
        throw FileUtilsError.invalidJPEGData
    }
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        try FileManager.default.removeItem(atPath: fileURL.path)
    }
    
    try data!.write(to: fileURL)
    
    return fileURL.standardizedFileURL.absoluteString
}

