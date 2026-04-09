//
//  ExampleViewController.swift
//  Boardy+VIP Standard
//

import UIKit

final class ExampleViewController: UIViewController, ExampleViewable {
    var interactor: ExampleInteractable!

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let submitButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor.didBecomeActive()
    }

    private func setupUI() {
        // Layout and styling (Humble Object: minimal logic)
        view.addSubview(titleLabel)
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }

    @objc private func didTapSubmit() {
        interactor.userDidSubmit()
    }

    // MARK: - Rendering
    func render(_ viewModel: ExampleViewModel) {
        titleLabel.text = viewModel.title
        // Update other UI elements using the pre-formatted viewModel
    }

    func renderError(_ message: String) {
        // Show alert or error state
    }
}
