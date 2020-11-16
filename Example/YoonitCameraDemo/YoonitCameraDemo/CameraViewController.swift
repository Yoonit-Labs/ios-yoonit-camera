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
import YoonitCamera
import DropDown

class CameraViewController: UIViewController {

    @IBOutlet var savedFrame: UIImageView!
    @IBOutlet var cameraView: CameraView!
    @IBOutlet var cameraTypeDropDown: UIButton!
    @IBOutlet var qrCodeTextField: UITextField!
    
    var showImagePreview = false
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "No capture",
            "Face capture",
            "Code capture",
            "Frame capture"
        ]
        return menu
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(onBackground),
                name: UIScene.willDeactivateNotification,
                object: nil)

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(onActive),
                name: UIScene.willEnterForegroundNotification,
                object: nil)
        
        self.showImagePreview = true
        self.qrCodeTextField.isHidden = true
        
        self.cameraView.cameraEventListener = self
        self.cameraView.startPreview()
        self.cameraView.startCaptureType(captureType: "face")
        
        self.menu.anchorView = self.cameraTypeDropDown
        self.menu.selectionAction = { index, title in
            var captureType = "none"
            
            if (title == "No capture") {
                self.cameraTypeDropDown.setTitle("No capture", for: .normal)
                captureType = "none"
                self.clearFaceImagePreview()
                self.qrCodeTextField.isHidden = true
                
            } else if (title == "Face capture") {
                self.cameraTypeDropDown.setTitle("Face capture", for: .normal)
                captureType = "face"
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
                
            } else if (title == "Code capture") {
                self.cameraTypeDropDown.setTitle("Code capture", for: .normal)
                captureType = "barcode"
                self.qrCodeTextField.isHidden = false
                self.clearFaceImagePreview()
                
            } else if (title == "Frame capture") {
                self.cameraTypeDropDown.setTitle("Frame capture", for: .normal)
                captureType = "frame"
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
            }
            
            self.cameraView.startCaptureType(captureType: captureType)
        }
    }
        
    @objc func onBackground(_ notification: Notification) {
        // For testing...
        
        self.cameraView.stopCapture()
    }
    
    @objc func onActive(_ notification: Notification) {
        // For testing...
        
        self.cameraView.startPreview()
//        self.cameraView.startCaptureType(captureType: "face")
    }
  
    @IBAction func toggleCam(_ sender: UIButton) {
        if sender.currentTitle == "Front cam" {
            self.cameraView.toggleCameraLens()
            sender.setTitle("Back cam", for: .normal)
            
        } else {
            self.cameraView.toggleCameraLens()
            sender.setTitle("Front cam", for: .normal)
        }
    }
    
    @IBAction func stopCapture(_ sender: UIButton) {
        self.cameraView.stopCapture()
        self.clearFaceImagePreview()
        self.qrCodeTextField.isHidden = true
    }
    
    @IBAction func showDropDown(_ sender: UIButton) {
        self.menu.show()
    }
    
    @IBAction func toggleFaceDetectionBox(_ sender: UISwitch) {
        self.cameraView.setFaceDetectionBox(faceDetectionBox: sender.isOn)
    }
    
    func clearFaceImagePreview() {
        self.showImagePreview = false
        DispatchQueue.main.async {
            self.savedFrame.image = nil
        }
    }
}

extension CameraViewController: CameraEventListenerDelegate {
    
    func onFaceImageCreated(count: Int, total: Int, imagePath: String) {
        let subpath = imagePath.substring(from: imagePath.index(imagePath.startIndex, offsetBy: 7))
        let image = UIImage(contentsOfFile: subpath)
        
        if total == 0 {
            print("onImageCaptured: \(count).")
        } else {
            print("onImageCaptured: \(count) from \(total).")
        }
        
        self.savedFrame.image = self.showImagePreview ? image : nil
    }
    
    func onFrameImageCreated(count: Int, total: Int, imagePath: String) {
        let subpath = imagePath.substring(from: imagePath.index(imagePath.startIndex, offsetBy: 7))
        let image = UIImage(contentsOfFile: subpath)
        
        if total == 0 {
            print("onImageCaptured: \(count).")
        } else {
            print("onImageCaptured: \(count) from \(total).")
        }
        
        self.savedFrame.image = self.showImagePreview ? image : nil
    }
    
    func onFaceDetected(x: Int, y: Int, width: Int, height: Int) {
        print("onFaceDetected: x: \(x), y: \(y), width: \(width), height: \(height)")
    }
    
    func onFaceUndetected() {
        print("onFaceUndetected")
        DispatchQueue.main.async {
            self.savedFrame.image = nil
        }
    }

    func onEndCapture() {
        print("onEndCapture")
    }

    func onError(error: String) {
        print("onError: \(error)")
    }

    func onMessage(message: String) {
        print("onMessage: \(message)")
    }

    func onPermissionDenied() {
        print("onPermissionDenied")
    }

    func onBarcodeScanned(content: String) {
        print("onBarcodeScanned: \(content)")
        self.qrCodeTextField.text = content
    }
}
