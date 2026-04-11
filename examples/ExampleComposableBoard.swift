//
//  ExampleComposableBoard.swift
//  Boardy+VIP Standard
//

import Boardy
import Foundation
import UIKit

final class ExampleComposableBoard: ModernContinuableBoard, GuaranteedBoard {
    typealias InputType = ExampleDashboardInput

    private let builder: ExampleDashboardBuildable

    init(identifier: BoardID, builder: ExampleDashboardBuildable, producer: ActivatableBoardProducer) {
        self.builder = builder
        super.init(identifier: identifier, boardProducer: producer)
    }

    func activate(withGuaranteedInput input: InputType) {
        let component = builder.build(withDelegate: self, input: input)
        let viewController = component.userInterface
        
        watch(content: component.controller)
        motherboard.putIntoContext(viewController)

        // 1. Attach Composable Motherboard to the Workflow Owner.
        // In most UI scenarios, the owner is a UIViewController, but it can be any object
        // that controls the shared lifecycle of the composition.
        let composableMain = attachComposableMotherboard(to: viewController)

        // 2. Concurrent Activation of children via ServiceMap
        // Both TabA and TabB are alive and active simultaneously
        composableMain.serviceMap.modPlugins.ioTabA.activation.activate(with: .init())
        composableMain.serviceMap.modPlugins.ioTabB.activation.activate(with: .init())

        // 3. Coordination between children
        // Catch output from TabA and send command to TabB via the Parent Board
        composableMain.serviceMap.modPlugins.ioTabA.flow.addTarget(composableMain) { main, output in
            switch output {
            case .didChangeSelection(let id):
                main.serviceMap.modPlugins.ioTabB.interaction.send(command: .syncWithSelection(id))
            }
        }

        // 4. Interaction (Command) Handling for the Parent itself
        composableMain.serviceMap.modPlugins.ioTabB.flow.addTarget(self) { target, output in
            switch output {
            case .requestParentRefresh:
                target.refreshBus.transport()
            }
        }

        // 5. Connect Workflow bridge directly to the component's Controller
        refreshBus.connect(target: component.controller) { controller in
            controller.reloadData()
        }

        switchBus.connect(target: component.controller) { controller, destination in
            controller.switchTab(to: destination)
        }

        rootViewController.pushViewController(viewController, animated: true)
    }

    // MARK: - Private properties

    private let switchBus = Bus<ExampleTabDestination>()
    private let refreshBus = Bus<Void>()

    private var controller: ExampleDashboardControllable? {
        lastAvailableWatchedContent()
    }
}
