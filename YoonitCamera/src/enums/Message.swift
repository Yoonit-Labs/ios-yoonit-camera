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

import Foundation

public enum Message: String {
    
    // Face/QRCode width percentage in relation of the screen width is less than the set.
    case INVALID_MINIMUM_SIZE = "INVALID_MINIMUM_SIZE"
    
    // Face/QRCode width percentage in relation of the screen width is more than the set.
    case INVALID_MAXIMUM_SIZE = "INVALID_MAXIMUM_SIZE"
    
    // Face bounding box is out of the setted region of interest.
    case INVALID_OUT_OF_ROI = "INVALID_OUT_OF_ROI"
    
    // Not available with camera lens "front".
    case INVALID_TORCH_LENS_USAGE = "INVALID_TORCH_LENS_USAGE"
}
