//
//  ExampleBoard.swift
//  Boardy+VIP Standard
//

import Boardy
import Foundation
import UIKit

final class ExampleBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = ExampleInput
    typealias OutputType = ExampleOutput
    typealias FlowActionType = ExampleAction
    typealias CommandType = ExampleCommand

    private let builder: ExampleBuildable

    init(identifier: BoardID, builder: ExampleBuildable, producer: ActivatableBoardProducer) {
        self.builder = builder
        super.init(identifier: identifier, boardProducer: producer)
    }

    func activate(withGuaranteedInput input: InputType) {
        let component = builder.build(withDelegate: self, input: input)
        let viewController = component.userInterface
        
        // Register the controller as watched content for Boardy context
        watch(content: component.controller)
        motherboard.putIntoContext(viewController)

        // Standard: Connect buses directly to the built component's controller/view
        refreshBus.connect(target: component.controller) { target in
            target.reloadData()
        }

        // Standard: Connectivity with specific instance validation (source === target)
        unavailableBus.connect(target: component.controller) { target, source in
            if source === target {
                // Handle specific instance event
            }
        }

        // Navigation logic
        rootViewController.pushViewController(viewController, animated: true)
    }

    /// 3rd Pillar: Interaction (Command)
    func interact(guaranteedCommand: CommandType) {
        switch guaranteedCommand {
        case .refresh:
            refreshBus.transport()
        case .updateData:
            // Forward to internal components
            break
        }
    }

    private func registerFlows() {
        // Enforce ServiceMap for cross-module flows
        // motherboard.serviceMap.modOtherPlugins.ioOther.flow.bind(to: locationPermissionBus)
    }

    // MARK: - Private properties

    private let refreshBus = Bus<Void>()
    private let unavailableBus = Bus<ExampleControllable>()

    private var controller: ExampleControllable? {
        lastAvailableWatchedContent()
    }
}

extension ExampleBoard: ExampleDelegate {
    func didFinish() {
        sendOutput(.done)
    }

    func didCancel() {
        sendOutput(.cancel)
    }
}
