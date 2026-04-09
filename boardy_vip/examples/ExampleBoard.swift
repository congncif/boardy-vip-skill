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

        // Navigation logic (e.g., push or present)
        rootViewController.pushViewController(viewController, animated: true)
    }

    func interact(guaranteedCommand: CommandType) {
        switch guaranteedCommand {
        case .refresh:
            // Forward command to interactor
            interactor?.reloadData()
        }
    }

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
