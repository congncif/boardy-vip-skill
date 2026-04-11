---
name: Boardy+VIP Architecture Standard
description: Standard instructions for building modular iOS applications using Boardy orchestration and the VIP (View-Interactor-Presenter) pattern following Clean Architecture and DDD principles.
version: 1.6.0
author: Antigravity AI
---

# Boardy+VIP Architecture Standard

This skill provides comprehensive instructions for designing, implementing, and integrating modular components using the **Boardy + VIP** architecture. This standard prioritizes Clean Architecture, Domain-Driven Design (DDD), and Unidirectional Data Flow.

## 1. Architectural Philosophy

The architecture is designed to handle high complexity in modular applications (Superapps) by ensuring strict separation of concerns, high testability, and "Plug-and-play" integration.

### Core Principles
- **Clean Architecture**: Separation of Business Logic from Frameworks/UI.
- **DDD (Domain-Driven Design)**: Business logic is centered around the Domain Layer.
- **Humble Object**: The View layer contains zero logic and is purely declarative.
- **Unidirectional Data Flow**: Data flows in one direction: View -> Interactor -> UseCase -> Presenter -> View.
- **Interface Segregation**: Implementation details are hidden behind lightweight Interface Modules.

---

## 2. Module Structure: Interface (IO) vs. Implementation (Plugins)

To optimize compilation times and decouple dependencies, every feature module is split into two distinct build targets.

### 2.1. Interface Module (`IO/`)
- **Naming**: `{FeatureName}`
- **Purpose**: Defines the public API. It is the only module clients should depend on.
- **Contents**:
    - **BoardID Extensions**: Public identifiers for the boards.
    - **Models**: `Input`, `Output`, `Command`, and `Action` data structures (The 4 Pillars).
    - **Destinations**: Strongly-typed activation interfaces.

### 2.2. Implementation Module (`Sources/`)
- **Naming**: `{FeatureName}Plugins`
- **Purpose**: Contains the private implementation logic.
- **Contents**:
    - **VIP Components**: Interactor, Presenter, View.
    - **Boards & Builders**: Concrete implementation and DI logic.
    - **Module Registration**: `ModuleBuilderPlugin` and `LauncherPlugin`.

---

## 3. Visibility & Scope (Minimal Export)

Following the **Minimal Export** philosophy, distinguish between Microboards based on their usage scope:

### 3.1. Public (Inter-module)
- **Use When**: The Microboard is an entry point called from other modules.
- **Location**: Define interfaces in the `IO/` target.
- **Requirement**: Use the `public` access modifier for all definitions.

### 3.2. Internal (Intra-module)
- **Use When**: The Microboard is a private sub-component used only within its own module.
- **Location**: Define interfaces alongside implementations in the `Plugins/` target (typically in `Sources/Microboards/.../`).
- **Requirement**: Use the default `internal` access level. Avoid `public`.

---

## 4. The 3 Pillars of Communication (ServiceMap)

Consistent communication between boards is achieved through the **ServiceMap** registry using these three pillars:

### 4.1. Activation (In)
- **Role**: Activates a new Microboard.
- **Pattern**: `mainboard.serviceMap.modB.ioB.activation.activate(with: input)`

### 4.2. Flow (Out/Callback)
- **Role**: Receives results or signals from a board (callbacks).
- **Pattern**: `mainboard.serviceMap.modB.ioB.flow.addTarget(self) { target, output in ... }`

### 4.3. Interaction (Command)
- **Role**: Sends reactive commands to an active board (alive).
- **Pattern**: `mainboard.serviceMap.modB.ioB.interaction.send(command: .refresh)`
- **Handling**: The destination board receives the command in `func interact(guaranteedCommand: CommandType)`.

---

## 5. Event Bus Communication (The Bridge)

Use `Bus<T>` to bridge event flows between the **Board** (coordination) and the **Controller** (managed object).

- **Initialization**: `private let resultBus = Bus<T>()`
- **Connect**: Performed within the `activate` method immediately after the Builder initializes the component. Connect directly to the `component.controller` for instance guarantee.
  ```swift
  resultBus.connect(target: component.controller) { target, data in
      target.handleData(data)
  }
  ```
- **Transport**: Performed within the Board's Flow/Interaction handlers.
  ```swift
  target.resultBus.transport(input: data)
  ```

---

## 6. VIP Component Boilerplates

### 6.1. Interactor
The brain of the unit. It orchestrates UseCases and manages state.

```swift
final class FeatureInteractor: AIInteractor {
    private let presenter: FeaturePresentable
    private let useCase: FeatureUseCase

    func didBecomeActive() {
        Task {
            do {
                let data = try await useCase.execute()
                await MainActor.run { presenter.presentData(data) }
            } catch {
                await MainActor.run { presenter.presentError(error) }
            }
        }
    }
}
```

### 6.2. Presenter
The UI Logic layer. Transforms Domain models into View Models.

```swift
final class FeaturePresenter: FeaturePresentable {
    weak var view: FeatureViewable!

    func presentData(_ domainModel: DomainModel) {
        let viewModel = ViewModel(title: domainModel.name.uppercaseed())
        view.render(viewModel)
    }
}
```

### 6.3. View (Humble Object)
Purely declarative. Forwards events to Interactor.

```swift
final class FeatureViewController: UIViewController, FeatureViewable {
    var interactor: FeatureInteractable!

    func render(_ viewModel: ViewModel) {
        titleLabel.text = viewModel.title
    }

    @objc func didTapSubmit() {
        interactor.submitAction()
    }
}
```

---

## 7. Service Layering (DDD)

Organize logic within `Sources/Services/` using the following layers:

### 7.1. Domain Layer (`Services/Domain/`)
- Pure Swift Models and Repository/Service **Protocols**.

### 7.2. Application Layer (`Services/Application/`)
- Atomic **UseCases**. Represents discrete business functions (e.g., `FetchUserProfileUseCase`).

### 7.3. Infrastructure Layer (`Services/Infra/`)
- Concrete implementation of Domain protocols (Network, DB, SDKs).

---

## 8. Global Integration System (Plugins)

To achieve a "Plug-and-play" architecture, features must be registered through a unified plugin system.

### 8.1. ModuleBuilderPlugin (Local Factory)
- **Role**: Groups related boards and builders within a module.
- **Implementation**:
```swift
struct FeatureModulePlugin: ModuleBuilderPlugin {
    func build(with identifier: BoardID, sharedComponent: any SharedValueComponent, internalContinuousProducer: any ActivatableBoardProducer) -> any ActivatableBoard {
        // Build the entry board for the module
    }

    func internalContinuousRegistrations(sharedComponent: any SharedValueComponent, producer: any ActivatableBoardProducer) -> [BoardRegistration] {
        // Register internal microboards
        [BoardRegistration(.modInternalFeature) { id in ... }]
    }
}
```

### 8.2. URLOpenerPlugin (Deep Link Handler)
- **Role**: Maps URL paths to board activations, decoupling navigation from logic.
- **Implementation**:
```swift
struct FeatureURLOpenerPlugin: URLOpenerPathMatchingPlugin {
    var matchingPath: String { "/feature-path" }
    func mainboard(_ mainboard: any FlowMotherboard, openURLWithParameters parameters: [String: String]) {
        // Activate microboard using ServiceMap
        mainboard.serviceMap.modFeaturePlugins.ioFeature
            .activation.activate(with: input)
    }
}
```

### 8.3. LauncherPlugin (Public Export)
- **Role**: Unified container that exports all module components to the App Core.
- **Implementation**:
```swift
public struct FeatureLauncherPlugin: LauncherPlugin {
    public func prepareForLaunching(withOptions options: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [FeatureModulePlugin()],
            urlOpenerPlugins: [FeatureURLOpenerPlugin()]
        )
    }
}
```

---

## 9. Testing Standards

High-quality Boardy+VIP modules must follow these testing rules:
- **Interactor Tests**: Verify that user actions trigger the correct Use Case calls and Presenter updates.
- **Presenter Tests**: Verify that Domain Models are correctly mapped to View Models (formatting, localization).
- **UseCase Tests**: Verify business logic correctness by mocking Infrastructure services.
- **Board Tests**: Verify correct activation and output emission.

---

## 10. Implementation Workflow

1. [ ] **Define Interface**: Create the `IO/` module with `BoardID`, `Input/Output`, and `Destination`.
2. [ ] **Domain Modeling**: Define models and service interfaces in `Services/Domain`.
3. [ ] **Implement UseCases**: Build the logic in `Services/Application`.
4. [ ] **Infra Bridge**: Implement external services in `Services/Infra`.
5. [ ] **VIP Wiring**: Implement the `Builder` and connect the components (Interactor, Presenter, View).
6. [ ] **Local Registration**: Register boards in `ModuleBuilderPlugin`.
7. [ ] **Deep Linking**: Implement `URLOpenerPlugin` if needed.
8. [ ] **Public Export**: Create `LauncherPlugin` and register it in the global `ServiceRegistry`.

---

## 11. Advanced Board Composition (ComposableMotherboard)

For complex features requiring simultaneous management of multiple active child boards (e.g., Vertical Composition, Multi-step Workflows, Dashboards), use **ComposableMotherboard**.

### 11.1. Core Pattern & Lifecycle Ownership
- **Principle**: The Composable Motherboard must be attached to the **Workflow Owner**—the object that controls the shared lifecycle of the composition.
- **UI Composition**: In most UI tasks, the owner is a `UIViewController`.
- **Method**: `let composableMain = attachComposableMotherboard(to: owner)`.

### 11.2. Communication in Composition
Child boards in a composition often coexist simultaneously, making **Interaction (Command)** the primary communication pillar.

1. **Parent to Child**: Parent sends instructions via `composableMain.serviceMap...interaction.send(command:)`.
2. **Child to Parent**: Child emits results via `Flow` or `Action`. The Parent Board catches these and bridges them to the Workflow Owner/Controller via `Bus`.
3. **Inter-Child Coordination**: The Parent Board acts as a central coordinator, catching output from one child board and triggering a command in another.

### 11.3. Composition Orchestration
The **Board** handles the business coordination of which child components should be active and how they interact. The **Workflow Owner** (e.g., a View or a Manager) handles the practical orchestration (e.g., UI assembly or resource management).

---
*Standard Version: 1.6.0*
