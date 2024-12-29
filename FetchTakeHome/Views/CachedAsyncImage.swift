//
//  CachedAsyncImage.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/28/24.
//

import SwiftUI

struct CachedAsyncImage: View {
    @State private var uiImage: UIImage?
    private var viewModel: CachedAsyncImageVM
    
    init(item: ImageCacheable) {
        self.viewModel = CachedAsyncImageVM(item: item)
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
            if let image = viewModel.fetchSavedImageFromDisk() {
                uiImage = image
            } else {
                // If UIImage doesn't exist on disk, load Image from URL
                let loadedImage: UIImage? = await viewModel.loadImageFromURL()
                uiImage = loadedImage

                // Save the loaded image to disk
                viewModel.saveImageToDisk(image: loadedImage)
            }
        }
    }
}


@Observable
class CachedAsyncImageVM {
    var item: ImageCacheable
    
    init(item: ImageCacheable) {
        self.item = item
    }
    
    func fetchSavedImageFromDisk() -> UIImage? {
        guard let url = getDocumentsDirectoryURL() else { return nil }
        
        let existingFileUrl = url.appendingPathComponent(item.fileName)
        // Attempt to load image from disk
        if FileManager.default.fileExists(atPath: existingFileUrl.path) {
            if let imageData = try? Data(contentsOf: existingFileUrl),
               let loadedImage = UIImage(data: imageData) {
                return loadedImage
            }
        }

        return nil
    }
    
    func loadImageFromURL() async -> UIImage? {
        guard let urlString = item.imageUrl, let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Load Image Error: \(error.localizedDescription)")
            return nil
        }
    }
        
    func saveImageToDisk(image: UIImage?) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.9),
              let url = getDocumentsDirectoryURL() else {
            return
        }
        
        let fileURL = url.appendingPathComponent(item.fileName)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Failed to save image with name: \(item.fileName) to disk with error: \(error.localizedDescription)")
        }
    }
        
    private func getDocumentsDirectoryURL() -> URL? {
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        return FileManager.default.urls(for: .documentDirectory, in: userDomainMask).first
    }
}

