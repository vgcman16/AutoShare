// Models/AppError.swift

import Foundation

enum AppError: Error, LocalizedError {
    case databaseError(String)
    case validationError(String)
    case authenticationError(String)
    case imageUploadError(String)
    // Add other custom error cases as needed

    var errorDescription: String? {
        switch self {
        case .databaseError(let message),
             .validationError(let message),
             .authenticationError(let message),
             .imageUploadError(let message):
            return message
        }
    }
}
