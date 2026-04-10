//
//  ExampleIO.swift
//  Boardy+VIP Standard
//
//  Note: This file should be located in the IO/ target.
//  Use 'public' modifiers for all components to allow inter-module access.
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubExample: BoardID = "pub.mod.Example.default"
}

// MARK: - Models

public struct ExampleInput {
    public let id: String
    public init(id: String) { self.id = id }
}

public enum ExampleOutput {
    case done
    case cancel
}

public enum ExampleCommand {
    case refresh
    case updateData(Any)
}

public enum ExampleAction: BoardFlowAction {
    case deepLink(URL)
}

// MARK: - Interface

/// Typed destination for ServiceMap integration
public typealias ExampleMainDestination = MainboardGenericDestination<ExampleInput, ExampleOutput, ExampleCommand, ExampleAction>

extension MotherboardType where Self: FlowManageable {
    /// Interface for Activation, Flow, and Interaction
    public func ioExample(_ identifier: BoardID = .pubExample) -> ExampleMainDestination {
        ExampleMainDestination(destinationID: identifier, mainboard: self)
    }
}
