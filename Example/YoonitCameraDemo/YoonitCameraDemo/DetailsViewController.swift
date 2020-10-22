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


import UIKit
import Foundation


class DetailsViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    var selectedImagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = selectedImage{
            if let imageToLoad = loadImageFromDiskWith(fileName: name) {
                imageView.image = imageToLoad
            }
        }
    }
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {

        let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirPath = tempDirectory.path
        let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
        selectedImagePath = imageUrl.path
        let image = UIImage(contentsOfFile: imageUrl.path)
        print("Exibindo \(imageUrl.path)")
        return image
    }
}
