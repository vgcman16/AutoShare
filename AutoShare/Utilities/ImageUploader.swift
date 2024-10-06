// Services/ImageUploader.swift

import Foundation
import FirebaseStorage
import UIKit

struct ImageUploader {
    /// Uploads an image to Firebase Storage and returns its download URL as a string.
    /// - Parameters:
    ///   - image: The `UIImage` to be uploaded.
    ///   - folder: The folder path in Firebase Storage where the image will be stored.
    /// - Returns: The download URL of the uploaded image as a `String`.
    /// - Throws: An `NSError` if the image processing or upload fails.
    static func uploadImage(image: UIImage, folder: String) async throws -> String {
        // Convert the UIImage to JPEG data with a compression quality of 0.8
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageUploader", code: 400, userInfo: [NSLocalizedDescriptionKey: "Unable to process image."])
        }
        
        // Create a unique filename using UUID
        let filename = UUID().uuidString + ".jpg"
        
        // Reference to the specific folder and file in Firebase Storage
        let storageRef = Storage.storage().reference().child("\(folder)/\(filename)")
        
        // Metadata for the uploaded image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            // Upload the image data to Firebase Storage
            _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            
            // Retrieve the download URL of the uploaded image
            let downloadURL = try await storageRef.downloadURL()
            
            return downloadURL.absoluteString
        } catch {
            // Throw an NSError with a descriptive message if the upload fails
            throw NSError(domain: "ImageUploader", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error uploading image: \(error.localizedDescription)"])
        }
    }
}
