//
//  FaceAnalyzerStatus.swift
//  YoonitCamera
//
//  Created by Marcio Habigzang Brufatto on 15/10/20.
//

import Foundation

@objc
public enum FaceAnalyzerStatus: Int {
    case IDLE = 0
    case RUNNING = 1
    case PAUSED = 2
}
