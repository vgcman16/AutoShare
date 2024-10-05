// ImageUploader.swift

import Foundation
import FirebaseStorage
import UIKit

class ImageUploader {
    static func uploadImage(image: UIImage, folder: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG."])))
            return
        }

        // Create a unique identifier for the image
        let imageID = UUID().uuidString

        // Create a reference to Firebase Storage
        let storageRef = Storage.storage().reference().child("\(folder)/\(imageID).jpg")

        // Set metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload the image data
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // Retrieve the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "DownloadURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve download URL."])))
                }
            }
        }
    }
}
