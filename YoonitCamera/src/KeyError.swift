//
// +-+-+-+-+-+-+
// |y|o|o|n|i|t|
// +-+-+-+-+-+-+
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// | Yoonit Camera lib for iOS applications                          |
// | Haroldo Teruya @ Cyberlabs AI 2020                              |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
//


import Foundation

public enum KeyError: String {
    
    // Tried to start a process that depends on to start the camera preview.
    case NOT_STARTED_PREVIEW = "NOT_STARTED_PREVIEW"
    
    // Tried to start a non-existent capture type.
    case INVALID_CAPTURE_TYPE = "INVALID_CAPTURE_TYPE"
    
    // Tried to input invalid face/frame number of images to capture.
    case INVALID_NUMBER_OF_IMAGES = "INVALID_NUMBER_OF_IMAGES"
    
    // Tried to input invalid face/frame time interval to capture.
    case INVALID_TIME_BETWEEN_IMAGES = "INVALID_TIME_BETWEEN_IMAGES"
    
    // Tried to input invalid face padding percent.
    case INVALID_FACE_PADDING_PERCENT = "INVALID_FACE_PADDING_PERCENT"
    
    // Tried to input invalid image width or height.
    case INVALID_FACE_IMAGE_SIZE = "INVALID_FACE_IMAGE_SIZE"
    
    // Tried to input invalid face capture minimum size.
    case INVALID_FACE_CAPTURE_MIN_SIZE = "INVALID_FACE_CAPTURE_MIN_SIZE"
    
    // Tried to input invalid face capture maximum size.
    case INVALID_FACE_CAPTURE_MAX_SIZE = "INVALID_FACE_CAPTURE_MAX_SIZE"
    
    // Tried to input invalid frame number of images to capture.
    case INVALID_FRAME_NUMBER_OF_IMAGES = "INVALID_FRAME_NUMBER_OF_IMAGES"
    
    // Tried to input invalid frame time interval to capture face.
    case INVALID_FRAME_TIME_BETWEEN_IMAGES = "INVALID_FRAME_TIME_BETWEEN_IMAGES"
    
    // Tried to input invalid face region of interesting offset.
    case INVALID_FACE_ROI_OFFSET = "INVALID_FACE_ROI_OFFSET"
    
    // Tried to input invalid face region of interest minimum size.
    case INVALID_FACE_ROI_MIN_SIZE = "INVALID_FACE_ROI_MIN_SIZE"
}
