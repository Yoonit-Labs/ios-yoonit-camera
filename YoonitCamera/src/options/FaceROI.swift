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
import AVFoundation

/**
 Model to set face region of interest.
 */
public class FaceROI {
    
    // Enable or disable ROI.
    var enable: Bool = false
    
    // Region of interest in percentage.
    // Values valid [0, 1].
    var topOffset: Float = 0     // "Above" the face detected.
    var rightOffset: Float = 0   // "Right" of face detected.
    var bottomOffset: Float = 0  // "Bottom" face detected.
    var leftOffset: Float = 0    // "Left" face detected.
}
