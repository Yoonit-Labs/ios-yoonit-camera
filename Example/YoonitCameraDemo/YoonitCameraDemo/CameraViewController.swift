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
    @IBOutlet var faceDetectionBoxSwitch: UISwitch!
    @IBOutlet var imageCaptureSwitch: UISwitch!
    
    var showImagePreview = false
    
    var captureType: String = "none" {
        didSet {
            switch self.captureType {
            case "none":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("No capture", for: .normal)
                self.clearFaceImagePreview()
                self.qrCodeTextField.isHidden = true
                return;
                
            case "face":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("Face capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
                return;
                
            case "frame":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("Frame capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
                return;
                
            case "qrcode":
                self.cameraView.startCaptureType(self.captureType)
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
        
        self.cameraView.setFaceDetectionBox(true)
        self.cameraView.setSaveImageCaptured(true)
        
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
            self.cameraView.setCameraLens("back")
            sender.setTitle("Back cam", for: .normal)
        } else {
            self.cameraView.setCameraLens("front")
            sender.setTitle("Front cam", for: .normal)
        }
        
        print("camera lens \(self.cameraView.getCameraLens())")
    }
    
    @IBAction func showDropDown(_ sender: UIButton) {
        self.menu.show()
    }
    
    @IBAction func toggleFaceDetectionBox(_ sender: UISwitch) {
        self.cameraView.setFaceDetectionBox(sender.isOn)
    }
    
    @IBAction func toggleCameraOn(_ sender: UISwitch) {    
        if sender.isOn {
            self.cameraView.startPreview()
        } else {
            self.cameraView.destroy()
            self.clearFaceImagePreview()
            self.captureType = "none"
            self.faceDetectionBoxSwitch.isOn = false
            self.imageCaptureSwitch.isOn = false
        }
    }
    
    @IBAction func toggleSaveImageCaptured(_ sender: UISwitch) {
        self.cameraView.setSaveImageCaptured(sender.isOn)
        
        if sender.isOn {
            self.showImagePreview = true
        } else {
            self.clearFaceImagePreview()
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
    
    func onImageCaptured(
        _ type: String,
        _ count: Int,
        _ total: Int,
        _ imagePath: String) {
        
        let subpath = imagePath.substring(from: imagePath.index(imagePath.startIndex, offsetBy: 7))
        let image = UIImage(contentsOfFile: subpath)
        
        if total == 0 {
            print("onImageCaptured \(type): \(count).")
        } else {
            print("onImageCaptured \(type): \(count) from \(total).")
        }
        
        self.savedFrame.image = self.showImagePreview ? image : nil
    }
    
    func onFaceDetected(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
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

    func onError(_ error: String) {
        print("onError: \(error)")
    }

    func onMessage(_ message: String) {
        print("onMessage: \(message)")
    }

    func onPermissionDenied() {
        print("onPermissionDenied")
    }

    func onQRCodeScanned(_ content: String) {
        print("onQRCodeScanned: \(content)")
        self.qrCodeTextField.text = content
    }
}
