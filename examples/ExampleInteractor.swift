//
//  ExampleInteractor.swift
//  Boardy+VIP Standard
//

import Foundation

final class ExampleInteractor {
    weak var delegate: ExampleDelegate?

    private let presenter: ExamplePresentable
    private let input: ExampleInput
    private let useCase: ExampleUseCase

    init(presenter: ExamplePresentable, input: ExampleInput, useCase: ExampleUseCase) {
        self.presenter = presenter
        self.input = input
        self.useCase = useCase
    }
}

// Internal VIP interface
extension ExampleInteractor: ExampleInteractable {
    func didBecomeActive() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let domainData = try await useCase.execute(withID: input.id)
                await MainActor.run { [weak self] in
                    self?.presenter.presentData(domainData)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.presenter.presentError(error)
                }
            }
        }
    }

    func userDidSubmit() {
        delegate?.didFinish()
    }
}

// Boardy layer interface: Referred to as 'Controller' from the Board
extension ExampleInteractor: ExampleControllable {
    func reloadData() {
        didBecomeActive()
    }
}
