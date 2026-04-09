//
//  ExampleIO.swift
//  Boardy+VIP Standard
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
}

public enum ExampleAction {
    case deepLink(URL)
}

// MARK: - Interface

public typealias ExampleMainDestination = MainboardGenericDestination<ExampleInput, ExampleOutput, ExampleCommand, ExampleAction>

extension MotherboardType where Self: FlowManageable {
    public func ioExample(_ identifier: BoardID = .pubExample) -> ExampleMainDestination {
        ExampleMainDestination(destinationID: identifier, mainboard: self)
    }
}
