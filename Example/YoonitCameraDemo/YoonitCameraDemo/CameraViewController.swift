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
    
    var captureType: String = "none" {
        didSet {
            switch self.captureType {
            case "none":
                self.cameraTypeDropDown.setTitle("No capture", for: .normal)
                self.clearFaceImagePreview()
                self.qrCodeTextField.isHidden = true
                return;
                
            case "face":
                self.cameraTypeDropDown.setTitle("Face capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
                return;
                
            case "frame":
                self.cameraTypeDropDown.setTitle("Frame capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
                return;
                
            case "qrcode":
                self.cameraTypeDropDown.setTitle("Code capture", for: .normal)
                self.qrCodeTextField.isHidden = false
                self.clearFaceImagePreview()
                return;
                
            default:
                return;
            }
        }
    }
    
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
        
        self.menu.anchorView = self.cameraTypeDropDown
        self.menu.selectionAction = {
            index, title in
                        
            switch title {
            case "No capture":
                self.captureType = "none"
                break;
                
            case "Face capture":
                self.captureType = "face"
                break;
                
            case "Frame capture":
                self.captureType = "frame"
                break;
                
            case "Code capture":
                self.captureType = "qrcode"
                break;
                
            default:
                self.captureType = "none"
                break;
            }
            
            self.cameraView.startCaptureType(captureType: self.captureType)
        }
    }
        
    @objc func onBackground(_ notification: Notification) {
        self.cameraView.stopCapture()
    }
    
    @objc func onActive(_ notification: Notification) {
        self.cameraView.startPreview()
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
    
    @IBAction func toggleFaceSaveImage(_ sender: UISwitch) {
        self.cameraView.setFaceSaveImages(faceSaveImages: sender.isOn)
        
        if !sender.isOn {
            self.clearFaceImagePreview()
        } else {
            self.showImagePreview = true
        }
    }
    
    func clearFaceImagePreview() {
        self.showImagePreview = false
        DispatchQueue.main.async {
            self.savedFrame.image = nil
        }
    }
}

extension CameraViewController: CameraEventListenerDelegate {
    
    func onImageCreated(
        type: String,
        count: Int,
        total: Int,
        imagePath: String) {
        
        let subpath = imagePath.substring(from: imagePath.index(imagePath.startIndex, offsetBy: 7))
        let image = UIImage(contentsOfFile: subpath)
        
        if total == 0 {
            print("onImageCaptured \(type): \(count).")
        } else {
            print("onImageCaptured \(type): \(count) from \(total).")
        }
        
        self.savedFrame.image = self.showImagePreview ? image : nil
    }
    
    func onFaceDetected(x: Int, y: Int, width: Int, height: Int) {
        print("onFaceDetected: x: \(x), y: \(y), width: \(width), height: \(height)")
    }
    
    func onFaceUndetected() {
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

    func onQRCodeScanned(content: String) {
        print("onQRCodeScanned: \(content)")
        self.qrCodeTextField.text = content
    }
}
