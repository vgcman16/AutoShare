// Models/AppError.swift

import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case databaseError(String)
    case validationError(String)
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message),
             .authenticationError(let message),
             .databaseError(let message),
             .validationError(let message),
             .unknownError(let message):
            return message
        }
    }
}
