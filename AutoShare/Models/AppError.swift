// Models/AppError.swift

import Foundation

enum AppError: LocalizedError {
    case databaseError(String)
    case validationError(String)
    // Add other error cases as needed

    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return message
        case .validationError(let message):
            return message
        }
    }
}
