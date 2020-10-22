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


let IMAGE_DIR = "facetrack"

enum FileUtilsError: Error {
    case invalidJPEGData
}

func fileURLFor(index: Int) -> URL {
    let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return tempDirectory.appendingPathComponent(String(format: "facetrack-%04d.jpg", index))
}

func save(image: UIImage, at fileURL: URL) throws -> String{
    let data = image.jpegData(compressionQuality: 1)

    if (data == nil) {
        throw FileUtilsError.invalidJPEGData
    }
    //Checks if file exists, removes it if so.
    if FileManager.default.fileExists(atPath: fileURL.path) {
        try FileManager.default.removeItem(atPath: fileURL.path)
    }

    try data!.write(to: fileURL)

    return fileURL.standardizedFileURL.absoluteString
}

func clearCapturedImages() {
    let fileManager = FileManager.default
    let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    let items = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
    items?.forEach { item in
        if item.absoluteString.contains("keyface"){
            try? fileManager.removeItem(at: item)
        }
    }
}

