/*
 * ██╗   ██╗ ██████╗  ██████╗ ███╗   ██╗██╗████████╗
 * ╚██╗ ██╔╝██╔═══██╗██╔═══██╗████╗  ██║██║╚══██╔══╝
 *  ╚████╔╝ ██║   ██║██║   ██║██╔██╗ ██║██║   ██║
 *   ╚██╔╝  ██║   ██║██║   ██║██║╚██╗██║██║   ██║
 *    ██║   ╚██████╔╝╚██████╔╝██║ ╚████║██║   ██║
 *    ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝
 *
 * https://yoonit.dev - about@yoonit.dev
 *
 * iOS Yoonit Camera
 * The most advanced and modern Camera module for iOS with a lot of awesome features
 *
 * Haroldo Teruya & Márcio Bruffato @ 2020-2021
 */

import UIKit
import YoonitCamera
import DropDown

class CameraViewController: UIViewController {
    
    private enum SegmentedIndex: Int {
        case CONFIGURATIONS = 0
        case ANALYSIS = 1
        case HIDE = 2
    }
    
    @IBOutlet var savedFrame: UIImageView!
    @IBOutlet var cameraView: CameraView!
    @IBOutlet var cameraTypeDropDown: UIButton!
    @IBOutlet var qrCodeTextField: UITextField!
    @IBOutlet var imageCapturedTextField: UITextField!
    @IBOutlet var detectionBoxSwitch: UISwitch!
    @IBOutlet var faceContoursSwitch: UISwitch!
    @IBOutlet var imageCaptureSwitch: UISwitch!
    @IBOutlet var configurationsView: UIView!
    @IBOutlet var analysisView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var leftEyeLabel: UILabel!
    @IBOutlet var leftEyeRawLabel: UILabel!
    @IBOutlet var rightEyeLabel: UILabel!
    @IBOutlet var rightEyeRawLabel: UILabel!
    @IBOutlet var smilingLabel: UILabel!
    @IBOutlet var smilingRawLabel: UILabel!
    @IBOutlet var verticalLabel: UILabel!
    @IBOutlet var verticalRawLabel: UILabel!
    @IBOutlet var horizontalLabel: UILabel!
    @IBOutlet var horizontalRawLabel: UILabel!
    @IBOutlet var tiltLabel: UILabel!
    @IBOutlet var tiltRawLabel: UILabel!
    @IBOutlet var sharpnessLabel: UILabel!
    @IBOutlet var sharpnessRawLabel: UILabel!
    @IBOutlet var darknessLabel: UILabel!
    @IBOutlet var darknessRawLabel: UILabel!
    @IBOutlet var lightnessLabel: UILabel!
    @IBOutlet var lightnessRawLabel: UILabel!
                
    var showImagePreview = false {
        didSet {
            self.imageCapturedTextField.isHidden = !self.showImagePreview
        }
    }
    
    var captureType: String = "none" {
        didSet {
            switch self.captureType {
            case "none":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("No capture", for: .normal)
                self.clearFaceImagePreview()
                self.qrCodeTextField.isHidden = true
            case "face":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("Face capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
            case "frame":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("Frame capture", for: .normal)
                self.showImagePreview = true
                self.qrCodeTextField.isHidden = true
            case "qrcode":
                self.cameraView.startCaptureType(self.captureType)
                self.cameraTypeDropDown.setTitle("Code capture", for: .normal)
                self.qrCodeTextField.isHidden = false
                self.clearFaceImagePreview()
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
                object: nil
            )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(onActive),
                name: UIScene.willEnterForegroundNotification,
                object: nil
            )
        
        self.showImagePreview = true
        self.qrCodeTextField.isHidden = true
        
        self.cameraView.cameraEventListener = self
        self.cameraView.startPreview()                            
        self.cameraView.setROILeftOffset(0.1)
        self.cameraView.setROIRightOffset(0.1)
        self.cameraView.setROITopOffset(0.1)
        self.cameraView.setROIBottomOffset(0.1)
        self.cameraView.setDetectionBox(true)
        self.cameraView.setSaveImageCaptured(true)
        self.captureType = "face"
        
        self.menu.anchorView = self.cameraTypeDropDown
        self.menu.selectionAction = { index, title in
            switch title {
            case "No capture":
                self.captureType = "none"
            case "Face capture":
                self.captureType = "face"
            case "Frame capture":
                self.captureType = "frame"
            case "Code capture":
                self.captureType = "qrcode"
            default:
                self.captureType = "none"
            }
        }
    }
        
    @objc func onBackground(_ notification: Notification) {
        self.cameraView.stopCapture()
    }
    
    @objc func onActive(_ notification: Notification) {
        self.cameraView.startPreview()
    }
            
    @IBAction func showDropDown(_ sender: UIButton) {
        self.menu.show()
    }
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case SegmentedIndex.CONFIGURATIONS.rawValue:
            self.configurationsView.isHidden = false
            self.analysisView.isHidden = true
        case SegmentedIndex.ANALYSIS.rawValue:
            self.configurationsView.isHidden = true
            self.analysisView.isHidden = false
        default:
            self.configurationsView.isHidden = true
            self.analysisView.isHidden = true
        }
    }
    
    @IBAction func toggleConfigurationsView(_ sender: UISwitch) {
        self.configurationsView.isHidden = !sender.isOn
    }
    
    @IBAction func onDetectionMinSwitchClick(_ sender: UISwitch) {
        self.cameraView.setDetectionMinSize(sender.isOn ? 0.7 : 0.0)
    }
    
    @IBAction func onDetectionMaxSwitchClick(_ sender: UISwitch) {
        self.cameraView.setDetectionMaxSize(sender.isOn ? 0.9 : 1.0)
    }
    
    @IBAction func toggleROI(_ sender: UISwitch) {
        self.cameraView.setROI(sender.isOn)
        self.cameraView.setROIAreaOffset(sender.isOn)
    }
    
    @IBAction func toggleROIColor(_ sender: UISwitch) {
        sender.isOn
            ? self.cameraView.setROIAreaOffsetColor(1, 1, 0, 0)
            : self.cameraView.setROIAreaOffsetColor(1, 1, 1, 1)
    }
  
    @IBAction func toggleCam(_ sender: UIButton) {
        if sender.currentTitle == "Front cam" {
            self.cameraView.setCameraLens("back")
            sender.setTitle("Back cam", for: .normal)
        } else {
            self.cameraView.setCameraLens("front")
            sender.setTitle("Front cam", for: .normal)
        }
    }
        
    @IBAction func toggleDetectionBox(_ sender: UISwitch) {
        self.cameraView.setDetectionBox(sender.isOn)
    }
    
    @IBAction func toggleDetectionBoxColor(_ sender: UISwitch) {
        sender.isOn
            ? self.cameraView.setDetectionBoxColor(1, 1, 0, 0)
            : self.cameraView.setDetectionBoxColor(1, 1, 1, 1)
    }
    
    @IBAction func toggleFaceContours(_ sender: UISwitch) {
        self.cameraView.setFaceContours(sender.isOn)
    }
    
    @IBAction func toggleContoursColor(_ sender: UISwitch) {
        sender.isOn
            ? self.cameraView.setFaceContoursColor(1, 1, 0, 0)
            : self.cameraView.setFaceContoursColor(1, 1, 1, 1)
    }
    
    @IBAction func toggleCameraOn(_ sender: UISwitch) {
        if sender.isOn {
            self.cameraView.startPreview()
        } else {
            self.cameraView.destroy()
            self.clearFaceImagePreview()
            self.captureType = "none"
            self.detectionBoxSwitch.isOn = false
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
    
    @IBAction func toggleTorch(_ sender: UISwitch) {
        self.cameraView.setTorch(sender.isOn)
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
        _ imagePath: String,
        _ darkness: NSNumber?,
        _ lightness: NSNumber?,
        _ sharpness: NSNumber?
    ) {
        let subpath = imagePath.substring(from: imagePath.index(imagePath.startIndex, offsetBy: 7))
        let image = UIImage(contentsOfFile: subpath)
        
        if total == 0 {
            print("onImageCaptured \(type): \(count).")
            self.imageCapturedTextField.text = "\(type): \(count)"
        } else {
            print("onImageCaptured \(type): \(count) / \(total).")
            self.imageCapturedTextField.text = "\(type): \(count) / \(total)"
        }
        
        if let darkness = darkness?.floatValue {
            self.darknessLabel.text = darkness > 0.7 ? "Too Dark" : "Normal"
            self.darknessRawLabel.text = String(format: "%.4f", darkness)
        }
        if let lightness = lightness?.floatValue {
            self.lightnessLabel.text = lightness > 0.65 ? "Too Light" : "Normal"
            self.lightnessRawLabel.text = String(format: "%.4f", lightness)
        }
        if let sharpness = sharpness?.floatValue {
            self.sharpnessLabel.text = sharpness < 0.1591 ? "Blurred" : "Normal"
            self.sharpnessRawLabel.text = String(format: "%.4f", sharpness)
        }
        self.savedFrame.image = self.showImagePreview ? image : nil
    }
    
    func onFaceDetected(
        _ x: Int,
        _ y: Int,
        _ width: Int,
        _ height: Int,
        _ leftEyeOpenProbability: NSNumber?,
        _ rightEyeOpenProbability: NSNumber?,
        _ smilingProbability: NSNumber?,
        _ headEulerAngleX: NSNumber?,
        _ headEulerAngleY: NSNumber?,
        _ headEulerAngleZ: NSNumber?
    ) {
        if let probability: Float = leftEyeOpenProbability?.floatValue {
            self.leftEyeLabel.text = probability > 0.8 ? "Open" : "Close"
            self.leftEyeRawLabel.text = String(format: "%.4f", probability)
        }
        if let probability: Float = rightEyeOpenProbability?.floatValue {
            self.rightEyeLabel.text = probability > 0.8 ? "Open" : "Close"
            self.rightEyeRawLabel.text = String(format: "%.4f", probability)
        }
        if let probability: Float = smilingProbability?.floatValue {
            self.smilingLabel.text = probability > 0.8 ? "Smiling" : "Not Smiling"
            self.smilingRawLabel.text = String(format: "%.4f", probability)
        }
        if let angle: Float = headEulerAngleX?.floatValue {
            var text = ""
            if angle < -36 {
                text = "Super Down"
            } else if -36 < angle && angle < -12 {
                text = "Down"
            } else if -12 < angle && angle < 12 {
                text = "Frontal"
            } else if 12 < angle && angle < 36 {
                text = "Up"
            } else if 36 < angle {
                text = "Super Up"
            }
            self.verticalLabel.text = text
            self.verticalRawLabel.text = String(format: "%.2f", angle)
        }
        if let angle: Float = headEulerAngleY?.floatValue {
            var text = ""
            if angle < -36 {
                text = "Super Left"
            } else if -36 < angle && angle < -12 {
                text = "Left"
            } else if -12 < angle && angle < 12 {
                text = "Frontal"
            } else if 12 < angle && angle < 36 {
                text = "Right"
            } else if 36 < angle {
                text = "Super Right"
            }
            self.horizontalLabel.text = text
            self.horizontalRawLabel.text = String(format: "%.2f", angle)
        }
        if let angle: Float = headEulerAngleZ?.floatValue {
            var text = ""
            if angle < -36 {
                text = "Super Right"
            } else if -36 < angle && angle < -12 {
                text = "Right"
            } else if -12 < angle && angle < 12 {
                text = "Frontal"
            } else if 12 < angle && angle < 36 {
                text = "Left"
            } else if 36 < angle {
                text = "Super Left"
            }
            self.tiltLabel.text = text
            self.tiltRawLabel.text = String(format: "%.2f", angle)
        }
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
