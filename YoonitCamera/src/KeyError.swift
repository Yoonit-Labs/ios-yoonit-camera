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
    case NOT_STARTED_PREVIEW = "NOT_STARTED_PREVIEW"
    case INVALID_CAPTURE_TYPE = "INVALID_CAPTURE_TYPE"
    case INVALID_CAPTURE_FACE_MIN_SIZE = "INVALID_CAPTURE_FACE_MIN_SIZE"
    case INVALID_CAPTURE_FACE_MAX_SIZE = "INVALID_CAPTURE_FACE_MAX_SIZE"
}
