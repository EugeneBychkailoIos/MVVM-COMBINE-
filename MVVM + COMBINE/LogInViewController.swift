//
//  LogInViewController.swift
//
//  Created by jekster on 9/2/21.
//

import UIKit
import Combine

final class LogInViewController: BaseViewController<LogInViewModel> {
    
    // MARK: -Outlets
    
    @IBOutlet private weak var signUpButton: DefaultButton!
    @IBOutlet private weak var emailView: CustomTextFieldWithLabels!
    @IBOutlet private weak var passwordView: CustomTextFieldWithLabels!
    @IBOutlet private weak var forgotPasswordButton: DefaultButton!
    @IBOutlet private weak var logInButton: DefaultButton!
    @IBOutlet private weak var serverErrorContainer: UIView!
    @IBOutlet private weak var serverErrorLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: OXYActivityIndicatorView!
    
    // MARK: - Private properties
    
    private var stateCancellable: Cancellable?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureUI()
        super.viewDidLoad()
        viewModel.start()
    }
    
    override func observeViewModelState() {
        stateCancellable = viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                render(state)
            })
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        typealias Authorization = Strings.Screen.Authorization
        typealias Login = Strings.Screen.Login
        
        emailView.setUpField(
            style: .emailField,
            placeholder: Login.TextField.Email.Placeholder.title,
            title: Login.Label.Textfield.Email.title
        )
        passwordView.setUpField(
            style: .passwordField,
            placeholder: Login.TextField.Password.Placeholder.title,
            title: Login.Label.Textfield.Password.title
        )
        forgotPasswordButton.setUp(
            style: .empty,
            title: Login.Button.ForgotPassword.title)
        logInButton.setUp(
            style: .contained,
            title: Login.Button.LogIn.title)
        signUpButton.setUp(
            style: .outlined,
            title: Authorization.Button.SignUp.title)
        
        emailView.delegate = self
        passwordView.delegate = self
    }
    
    private func render(_ state: LogInViewModel.State) {
        switch state {
        case .idle:
            serverErrorContainer.isHidden = true
            activityIndicatorView.stopAnimating()
        case .loading:
            view.endEditing(true)
            serverErrorContainer.isHidden = true
            activityIndicatorView.startAnimating()
        case let .started(startedState):
            if let emailError = startedState.emailError {
                emailView.state = .withError(emailError)
            } else {
                emailView.state = .normal
            }
            if let passwordError = startedState.passwordError {
                passwordView.state = .withError(passwordError)
            } else {
                passwordView.state = .normal
            }
            serverErrorContainer.isHidden = true
            activityIndicatorView.stopAnimating()
            logInButton.canBeEnabled(value: startedState.isButtonEnable)
        case let .failure(error):
            emailView.state = .withError("")
            passwordView.state = .withError("")
            view.isUserInteractionEnabled = true
            serverErrorContainer.isHidden = false
            serverErrorLabel.text = error
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func loginButtonAction(_ sender: Any) {
        viewModel.makeLogin()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        viewModel.coordinateToSignUp()
    }
    @IBAction private func forgetPasswordAction(_ sender: Any) {
        viewModel.coordinateToForgotPassword()
    }
}

// MARK: - Extensions

extension LogInViewController: DelegateCustomTextFieldWithLabels {
    func textFieldDidEndEditing(_ textField: CustomTextFieldWithLabels) {
        if emailView === textField {
            viewModel.inputEmail(emailView.getText())
        }
        if passwordView === textField {
            viewModel.inputPassword(passwordView.getText())
        }
        let emailText = emailView.getText()
        viewModel.inputEmail(emailText)
        let passwordText = passwordView.getText()
        viewModel.inputPassword(passwordText)
        viewModel.makeLogin()
    }
}
