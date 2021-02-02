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

import UIKit
import Foundation
import AVFoundation

/**
 Model to set face region of interest.
 */
public class FaceROI {
    
    // Enable or disable ROI.
    var enable: Bool = false
    
    // Enable or disable face region of interest area offset.
    var areaOffsetEnable: Bool = false

    // Face region of interest area offset color.
    var areaOffsetColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    
    // Region of interest in percentage.
    // Values valid [0, 1].
    var topOffset: CGFloat = 0     // "Above" the face detected.
    var rightOffset: CGFloat = 0   // "Right" of face detected.
    var bottomOffset: CGFloat = 0  // "Bottom" face detected.
    var leftOffset: CGFloat = 0    // "Left" face detected.
    
    // Minimum face size in percentage in relation of the ROI.
    var minimumSize: Float = 0
        
    // Return if any attributes has modifications.
    var hasChanges: Bool {
        get {
            return
                self.topOffset != 0.0 ||
                self.rightOffset != 0.0 ||
                self.bottomOffset != 0.0 ||
                self.leftOffset != 0.0
        }
    }
    
    /**
     Current offsets is out of the offset parameters.
     
     - Parameter topOffset: top offset.
     - Parameter rightOffset: right offset.
     - Parameter bottomOffset: bottom offset.
     - Parameter leftOffset: left offset.
     - Returns is out of the offset parameters.
     */
    public func isOutOf(
        topOffset: CGFloat,
        rightOffset: CGFloat,
        bottomOffset: CGFloat,
        leftOffset: CGFloat
    ) -> Bool {
        return
            self.topOffset > topOffset ||
            self.rightOffset > rightOffset ||
            self.bottomOffset > bottomOffset ||
            self.leftOffset > leftOffset
    }
}
