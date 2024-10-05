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

        do {
            _ = try await ref.putDataAsync(imageData, metadata: nil)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            throw AppError.networkError("Failed to upload image: \(error.localizedDescription)")
        }
    }
}
