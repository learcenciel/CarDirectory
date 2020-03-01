//
//  UITextField + Validation.swift
//  CarDirectory
//
//  Created by Alexander on 01.03.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import Foundation
import UIKit

protocol ValidatorConvertible {
    func validate(_ value: String?) throws -> String
}

enum ValidatorType {
    case manufacturer
    case model
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .manufacturer: return ManufacturerValidator()
        case .model: return ModelValidator()
        }
    }
}

struct ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

class ManufacturerValidator: ValidatorConvertible {
    func validate(_ value: String?) throws -> String {
        if let value = value, !value.isEmpty {
            return value
        }
        
        throw ValidationError("Manufacturer field is empty")
    }
}

class ModelValidator: ValidatorConvertible {
    func validate(_ value: String?) throws -> String {
        if let value = value, !value.isEmpty {
            return value
        }
        
        throw ValidationError("Model field is empty")
    }
}

extension UIViewController {
    func showAlert(_ error: String) {
        let alertController = UIAlertController(title: "All the fields are required.", message: error, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validate(self.text!)
    }
}
