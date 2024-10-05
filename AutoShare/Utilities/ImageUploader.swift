// Utilities/ImageUploader.swift

import Foundation
import FirebaseStorage
import UIKit

class ImageUploader {
    static func uploadImage(image: UIImage, folder: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AppError.validationError("Failed to compress image.")
        }

        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "\(folder)/\(filename).jpg")

        return try await withCheckedThrowingContinuation { continuation in
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: AppError.networkError("Failed to upload image: \(error.localizedDescription)"))
                    return
                }
                ref.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: AppError.networkError("Failed to get download URL: \(error.localizedDescription)"))
                        return
                    }
                    if let url = url {
                        continuation.resume(returning: url.absoluteString)
                    } else {
                        continuation.resume(throwing: AppError.networkError("Download URL is nil"))
                    }
                }
            }
        }
    }
}
