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

public enum Message: String {
    
    // Face width percentage in relation of the screen width is less than the CaptureOptions.faceCaptureMinSize
    case INVALID_CAPTURE_FACE_MIN_SIZE = "INVALID_CAPTURE_FACE_MIN_SIZE"
    
    // Face width percentage in relation of the screen width is more than the CaptureOptions.faceCaptureMinSize
    case INVALID_CAPTURE_FACE_MAX_SIZE = "INVALID_CAPTURE_FACE_MAX_SIZE"
    
    // Face bounding box is out of the setted region of interest.
    case INVALID_CAPTURE_FACE_OUT_OF_ROI = "INVALID_CAPTURE_FACE_OUT_OF_ROI"
    
    // Face width percentage in relation of the screen width is less than the CaptureOptions.FaceROI.minimumSize.
    case INVALID_CAPTURE_FACE_ROI_MIN_SIZE = "INVALID_CAPTURE_FACE_ROI_MIN_SIZE"
}
