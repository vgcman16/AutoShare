// ImageUploader.swift

import Foundation
import FirebaseStorage
import UIKit

class ImageUploader {
    
    /// Uploads a UIImage to Firebase Storage under the specified folder.
    /// - Parameters:
    ///   - image: The UIImage to upload.
    ///   - folder: The folder path in Firebase Storage (e.g., "vehicle_images", "driver_license_images").
    ///   - completion: Completion handler with Result containing the download URL string or an Error.
    static func uploadImage(image: UIImage, folder: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // Convert UIImage to JPEG data with compression quality of 0.8
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG."])))
            return
        }
        
        // Initialize Firebase Storage reference
        let storageRef = Storage.storage().reference()
        
        // Generate a unique identifier for the image
        let imageID = UUID().uuidString
        
        // Create a reference to the desired folder and image ID
        let imageRef = storageRef.child("\(folder)/\(imageID).jpg")
        
        // Upload the image data to Firebase Storage
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                // Handle upload error
                completion(.failure(error))
                return
            }
            
            // Retrieve the download URL after successful upload
            imageRef.downloadURL { url, error in
                if let error = error {
                    // Handle URL retrieval error
                    completion(.failure(error))
                    return
                }
                
                // Ensure the URL is valid and return it as a string
                if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "DownloadURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve download URL."])))
                }
            }
        }
    }
}
