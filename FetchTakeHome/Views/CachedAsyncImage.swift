//
//  CachedAsyncImage.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/28/24.
//

import SwiftUI

struct CachedAsyncImage: View {
    @State private var uiImage: UIImage?

    var item: ImageCacheable
    
    init(item: ImageCacheable) {
        self.uiImage = nil
        self.item = item
    }

    var body: some View {
        VStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .foregroundStyle(.white)
                    .font(.system(size: 60))
                    .background(.gray)
            }
        }
        .task {
            // NOTE: Checking for an existing file using "fileName" before we
            // validate the presence of "urlString" because in a real-world maybe we
            // saved that file in previous screen/transaction.
            uiImage = fetchSavedImageFromDisk(fileName: item.fileName)

            if let imageUrl = item.smallImageUrl, uiImage == nil {
                // If UIImage doesn't exist on disk, load Image from URL
                let loadedImage: UIImage? = await loadImageFromURL(urlString: imageUrl)
                uiImage = loadedImage
                
                // Save the image to disk
                saveImageToDisk(image: loadedImage, fileName: item.fileName)
            }
        }
    }
    
    private func fetchSavedImageFromDisk(fileName: String?) -> UIImage? {
        guard let fileName, let url = getDocumentsDirectoryURL() else { return nil }
        
        let existingFileUrl = url.appendingPathComponent(fileName)
        // Attempt to load image from disk
        if FileManager.default.fileExists(atPath: existingFileUrl.path) {
            if let imageData = try? Data(contentsOf: existingFileUrl),
               let loadedImage = UIImage(data: imageData) {
                return loadedImage
            }
        }

        return nil
    }
    
    private func loadImageFromURL(urlString: String?) async -> UIImage? {
        guard let urlString, let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Load Image Error: \(error.localizedDescription)")
            return nil
        }
    }
        
    private func saveImageToDisk(image: UIImage?, fileName: String) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.9),
              let url = getDocumentsDirectoryURL() else {
            return
        }
        
        let fileURL = url.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Failed to save image to disk with error: \(error.localizedDescription)")
        }
    }
        
    private func getDocumentsDirectoryURL() -> URL? {
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        return FileManager.default.urls(for: .documentDirectory, in: userDomainMask).first
    }
}

#Preview {
    CachedAsyncImage()
}
