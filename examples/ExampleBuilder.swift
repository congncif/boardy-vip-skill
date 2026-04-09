//
//  ExampleBuilder.swift
//  Boardy+VIP Standard
//

import UIKit

protocol ExampleBuildable {
    func build(withDelegate delegate: ExampleDelegate?, input: ExampleInput) -> ExampleInterface
}

struct ExampleBuilder: ExampleBuildable {
    func build(withDelegate delegate: ExampleDelegate?, input: ExampleInput) -> ExampleInterface {
        // UI Layer
        let viewController = ExampleViewController()
        
        // Presentation Layer
        let presenter = ExamplePresenter()
        presenter.view = viewController
        
        // Domain/Application Layer
        let useCase = ExampleUseCaseInteractor()
        
        // Business Logic Layer
        let interactor = ExampleInteractor(
            presenter: presenter,
            input: input,
            useCase: useCase
        )
        interactor.delegate = delegate
        
        // Link View back to Interactor
        viewController.interactor = interactor
        
        return ExampleInterface(userInterface: viewController, controller: interactor)
    }
}
