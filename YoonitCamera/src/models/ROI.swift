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
import Foundation
import AVFoundation

/**
 Model to set region of interest.
 */
public class ROI {
    
    // Enable or disable ROI.
    var enable: Bool = false
    
    // Enable/disable region of interest area offset.
    var areaOffsetEnable: Bool = false

    // Region of interest area offset color.
    var areaOffsetColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
    
    // Region of interest in percentage.
    // Values valid [0, 1].
    var topOffset: CGFloat = 0
    var rightOffset: CGFloat = 0
    var bottomOffset: CGFloat = 0
    var leftOffset: CGFloat = 0
        
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
