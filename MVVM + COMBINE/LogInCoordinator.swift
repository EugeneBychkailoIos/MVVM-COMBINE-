//
//  LogInCoordinator.swift
//
//  Created by jekster on 9/2/21.
//

import UIKit

final class LogInCoordinator: BaseCoordinator<Void> {
    
    // MARK: - Public methods
    
    override func start() {
        let viewModel = LogInViewModel(coordinator: self, authorizationService: container.authorizationService)
        let viewController = LogInViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openSignUpFlow() {
        let coordinator = SignUpCoordinator(navigationController: navigationController, container: container)
        coordinator.onComplete = onComplete
        coordinate(to: coordinator)
    }
    
    func openForgotFlow() {}
    
    func openForgetPasswordScreen() {
        let service = ForgetPasswordService()
        let viewModel = ForgetPasswordViewModel(coordinator: self, service: service)
        let viewController = ForgetPasswordViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openCheckYourEmailScreen(_ email: String?) {
        guard navigationController.topViewController is ForgetPasswordViewController else {
            return
        }
        let service = ForgetPasswordService()
        let viewModel = CheckYourEmailViewModel(
            coordinator: self,
            forgetPasswordService: service,
            email: email
        )
        let viewController = CheckYourEmailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func logIn() {
        navigationController.popToRootViewController(animated: true)
    }

    func goBack() {
        navigationController.popViewController(animated: true)
    }

    func openMainFlow() {
//        onComplete?(())
        let coordinator = ProfileCoordinator(navigationController: navigationController, container: container)
        coordinator.onComplete = onComplete
        coordinate(to: coordinator)
    }
    
    // MARK: - Private properties
    
    private unowned let navigationController: UINavigationController
    private unowned let container: DIContainer
    
    // MARK: - Init
    
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
}
