// Models/AppError.swift

import Foundation

enum AppError: LocalizedError {
    case databaseError(String)
    case validationError(String)
    case networkError(String) // Added networkError case
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return message
        case .validationError(let message):
            return message
        case .networkError(let message):
            return message
        }
    }
}
