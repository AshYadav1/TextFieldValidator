//
//  TextfieldValidator.swift
//
//  Created by Ashish on 11/07/24.
//

import Foundation

protocol Validation {
    associatedtype Value: ExpressibleByStringLiteral
    associatedtype Failure: Error
    func validation(_ value: Value) -> Result<Value, Failure>
}

typealias ErrorMessage = String
extension ErrorMessage: Error {}

struct ValidationRule: Validation {
    
    /// Mention the type of validation
    enum Validations {
        case email
        case phoneNumber
    }
    
    let type: Validations
    
    /// It is used for implement the logic of validation
    /// - Parameter value: Itshould always be string as it conform from ExpressibleByStringLiteral protocol
    /// - Returns: Result which contain a value if success otherwise a error in string.
    func validation(_ value: String) -> Result<String, ErrorMessage> {
        
        switch type {
        case .email:
            guard !value.isEmpty else {
                return .failure("Please enter Email address.")
            }
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
            let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            guard emailTest.evaluate(with: value) else {
                return .failure("Please enter valid Email address.")
            }
            return .success(value)
            
        case .phoneNumber:
            guard !value.isEmpty else {
                return .failure("Please enter Phone number.")
            }
            
            guard value.count < 10 else {
                return .failure("Phone number shouldn't be less than 10 digits")
            }
            return .success(value)
        }
    }
}

@propertyWrapper
struct TextfieldValidator<Rule: Validation> {
    var wrappedValue: Rule.Value
    private var rule: Rule
    
    init(wrappedValue: Rule.Value, rule: Rule) {
        self.wrappedValue = wrappedValue
        self.rule = rule
    }
}

extension TextfieldValidator {
    public var projectedValue: Result<Rule.Value, Rule.Failure> { rule.validation(wrappedValue) }
}
