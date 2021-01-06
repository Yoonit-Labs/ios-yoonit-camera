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
        
    // Tried to start a non-existent capture type.
    case INVALID_CAPTURE_TYPE = "INVALID_CAPTURE_TYPE"
    
    // Tried to input invalid camera lens.
    case INVALID_CAMERA_LENS = "INVALID_CAMERA_LENS"
    
    // Tried to input invalid face/frame number of images to capture.
    case INVALID_NUMBER_OF_IMAGES = "INVALID_NUMBER_OF_IMAGES"
    
    // Tried to input invalid face/frame time interval to capture.
    case INVALID_TIME_BETWEEN_IMAGES = "INVALID_TIME_BETWEEN_IMAGES"
    
    // Tried to input invalid image width.
    case INVALID_OUTPUT_IMAGE_WIDTH = "INVALID_OUTPUT_IMAGE_WIDTH"

    // Tried to input invalid image height.
    case INVALID_OUTPUT_IMAGE_HEIGHT = "INVALID_OUTPUT_IMAGE_HEIGHT"
    
    // Tried to input invalid face padding percent.
    case INVALID_FACE_PADDING_PERCENT = "INVALID_FACE_PADDING_PERCENT"
        
    // Tried to input invalid face capture minimum size.
    case INVALID_FACE_CAPTURE_MIN_SIZE = "INVALID_FACE_CAPTURE_MIN_SIZE"
    
    // Tried to input invalid face capture maximum size.
    case INVALID_FACE_CAPTURE_MAX_SIZE = "INVALID_FACE_CAPTURE_MAX_SIZE"
        
    // Tried to input invalid face region of interest top offset.
    case INVALID_FACE_ROI_TOP_OFFSET = "INVALID_FACE_ROI_TOP_OFFSET"

    // Tried to input invalid face region of interest right offset.
    case INVALID_FACE_ROI_RIGHT_OFFSET = "INVALID_FACE_ROI_RIGHT_OFFSET"

    // Tried to input invalid face region of interest bottom offset.
    case INVALID_FACE_ROI_BOTTOM_OFFSET = "INVALID_FACE_ROI_BOTTOM_OFFSET"

    // Tried to input invalid face region of interest left offset.
    case INVALID_FACE_ROI_LEFT_OFFSET = "INVALID_FACE_ROI_LEFT_OFFSET"

    // Tried to input invalid face region of interest minimum size.
    case INVALID_FACE_ROI_MIN_SIZE = "INVALID_FACE_ROI_MIN_SIZE"
}
