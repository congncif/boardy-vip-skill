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
        
        // Register the controller (Interactor) as watched content for Boardy context
        watch(content: component.controller)
        motherboard.putIntoContext(viewController)

        // Connect buses to Interactor
        refreshBus.connect(target: self) { target, _ in
            target.interactor?.reloadData()
        }

        // Navigation logic
        rootViewController.pushViewController(viewController, animated: true)
    }

    /// 3rd Pillar: Interaction (Command)
    func interact(guaranteedCommand: CommandType) {
        switch guaranteedCommand {
        case .refresh:
            // Transport command through Bus to active controller
            refreshBus.transport()
        case .updateData(let data):
            // Forward directly or via Bus
            print("Updating with data: \(data)")
        }
    }

    private func registerFlows() {
        // Correct Flow Syntax using ServiceMap (if observing another board)
        // motherboard.serviceMap.modOther.ioOther.flow.addTarget(self) { target, output in ... }
    }

    // MARK: - Private properties

    private let refreshBus = Bus<Void>()

    private var interactor: ExampleControllable? {
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
