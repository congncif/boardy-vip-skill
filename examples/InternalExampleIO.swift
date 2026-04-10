//
//  InternalExampleIO.swift
//  Boardy+VIP Standard
//
//  Note: This file should be located along with implementation in Sources/Microboards/...
//  Omit 'public' modifiers for internal (intra-module) microboards.
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modInternalFeature: BoardID = "mod.InternalFeature"
}

// MARK: - Models

struct InternalFeatureInput {
    let context: String
}

enum InternalFeatureOutput {
    case finished
}

typealias InternalFeatureCommand = Void

enum InternalFeatureAction: BoardFlowAction {}

// MARK: - Protocols

protocol InternalFeatureDelegate: AnyObject {
    func didFinish()
}
