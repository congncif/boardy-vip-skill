//
//  ExamplePresenter.swift
//  Boardy+VIP Standard
//

import Foundation

final class ExamplePresenter: ExamplePresentable {
    weak var view: ExampleViewable?

    func presentData(_ domainData: DomainModel) {
        // Transform Domain Model to View Model (Formatting, Localization)
        let title = domainData.name.uppercased()
        let description = "Last updated: \(Date())"
        
        let viewModel = ExampleViewModel(
            title: title,
            description: description
        )
        
        view?.render(viewModel)
    }

    func presentError(_ error: Error) {
        view?.renderError(error.localizedDescription)
    }
}
