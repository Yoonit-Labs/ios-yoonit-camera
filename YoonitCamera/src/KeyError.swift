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
        
    // Tried to input invalid capture minimum size.
    case INVALID_MINIMUM_SIZE = "INVALID_MINIMUM_SIZE"
    
    // Tried to input invalid capture maximum size.
    case INVALID_MAXIMUM_SIZE = "INVALID_MAXIMUM_SIZE"
        
    // Tried to input invalid region of interest top offset.
    case INVALID_ROI_TOP_OFFSET = "INVALID_ROI_TOP_OFFSET"

    // Tried to input invalid region of interest right offset.
    case INVALID_ROI_RIGHT_OFFSET = "INVALID_ROI_RIGHT_OFFSET"

    // Tried to input invalid region of interest bottom offset.
    case INVALID_ROI_BOTTOM_OFFSET = "INVALID_ROI_BOTTOM_OFFSET"

    // Tried to input invalid region of interest left offset.
    case INVALID_ROI_LEFT_OFFSET = "INVALID_ROI_LEFT_OFFSET"
    
    // Tried to input invalid region of interest area offset ARGB value color.
    case INVALID_ROI_COLOR = "INVALID_ROI_COLOR"
    
    // Tried to input invalid face contour ARGB value color.
    case INVALID_FACE_CONTOURS_COLOR = "INVALID_FACE_CONTOURS_COLOR"
}
