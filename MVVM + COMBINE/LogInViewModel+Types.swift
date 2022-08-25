//
//  LogInViewModel+Types.swift
//  oxy-ios
//
//  Created by Eugene on 9/2/21.
//

import Foundation

extension LogInViewModel {
    
    struct LoadedState: Equatable {
        let email: String?
        let password: String?
        let emailError: String?
        let passwordError: String?
        let isButtonEnable: Bool
    }
    
    enum State: Equatable {
        case idle
        case started(LoadedState)
        case loading
        case failure(String?)
    }
}
