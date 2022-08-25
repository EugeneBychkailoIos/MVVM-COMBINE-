//
//  LogInViewModel.swift
//
//  Created by jekster on 9/2/21.
//

import Foundation
import Combine

final class LogInViewModel {
    
    // MARK: - Public methods
    
    func start() {
        guard case .idle = state else {
            return
        }
        setStartedState()
    }
    
    func inputEmail(_ email: String) {
        inputEmail = email
        setStartedState()
    }
    
    func inputPassword(_ password: String) {
        inputPassword = password
        setStartedState()
    }

    func coordinateToForgotPassword() {
        coordinator?.openForgetPasswordScreen()
    }
    
    func coordinateToSignUp() {
        coordinator?.openSignUpFlow()
    }
    
    func makeLogin() {
        switch state {
        case .loading:
            return
        default:
            break
        }
        guard inputEmail != nil,
              inputPassword != nil,
              emailError == nil,
              passwordError == nil
        else {
            return
        }
        state = .loading
        authorizationService.login(email: inputEmail!, password: inputPassword!)
        authorizationService.accessToken()
    }
    
    // MARK: - Public properties
    
    @Published private(set) var state: State
    
    // MARK: - Private properties
    
    private unowned let authorizationService: AuthorizationService
    private weak var coordinator: LogInCoordinator?
    private var inputEmail: String?
    private var inputPassword: String?
    private let emailValidationRules: [ValidationRule] = [
        ValidateEmail()
    ]
    private let passwordValidationRules: [ValidationRule] = [
        ValidateMinimumLength(minimumLength: 8, emptyStringError: Strings.Screen.Error.Validation.Empty.Password.title),
        ValidateMaximumLenght(maximumLenght: 128)
    ]
    private var emailError: Error? {
        guard let email = inputEmail else {
            return nil
        }
        return emailValidationRules.compactMap({ $0.validate(email)}).first
    }
    private var passwordError: Error? {
        guard let password = inputPassword else {
            return nil
        }
        return passwordValidationRules.compactMap({ $0.validate(password)}).first
    }
    
    private var authorizationStateCancellable: Cancellable?
    
    // MARK: - Init
    
    init(coordinator: LogInCoordinator, authorizationService: AuthorizationService) {
        self.coordinator = coordinator
        self.authorizationService = authorizationService
        state = .idle
        observeAuthorizationServiceState()
    }
    
    // MARK: - Private methods
    
    private func observeAuthorizationServiceState() {
        authorizationStateCancellable = authorizationService.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .idle:
                    break
                case .authorized:
                    self?.coordinator?.openMainFlow()
                    break
                case let .unauthorized(error):
                    self?.setFailureState(error: error?.localizedDescription)
                case let .accessToken(token):
                    break
                }
            })
    }
    
    private func setStartedState() {
        switch state {
        case .loading:
            return
        default:
            break
        }
        
        let isEmailAvailable = !inputEmail.isNilOrEmptyString
        let isPasswordAvailable = !inputPassword.isNilOrEmptyString
        
        let loadedState = LoadedState(
            email: inputEmail,
            password: inputPassword,
            emailError: emailError?.localizedDescription,
            passwordError: passwordError?.localizedDescription,
            isButtonEnable: isEmailAvailable && isPasswordAvailable
        )
        state = .started(loadedState)
    }
    
    private func setFailureState(error: String?) {
        state = .failure(error)
    }
}
