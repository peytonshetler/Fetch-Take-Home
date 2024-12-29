//
//  CachedAsyncImage.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/28/24.
//

import SwiftUI

struct CachedAsyncImage: View {
    @State private var viewModel: CachedAsyncImageVM
    
    init(item: ImageCacheable) {
        self.viewModel = CachedAsyncImageVM(item: item)
    }

    var body: some View {
        VStack {
            if let image = viewModel.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(.gray)
                    .clipShape(Circle())
                    .frame(width: 90, height: 90)
            }
        }
        .task {
            await viewModel.loadImage()
        }
    }
}

#Preview {
    ContentView()
}


@Observable @MainActor
class CachedAsyncImageVM {
    var uiImage: UIImage? = nil
    var item: ImageCacheable

    init(item: ImageCacheable) {
        self.item = item
    }
    
    func loadImage() async {
        if let image = fetchSavedImageFromDisk() {
            uiImage = image
        } else {
            // If UIImage doesn't exist on disk, load Image from URL
            let loadedImage: UIImage? = await loadImageFromURL()
            uiImage = loadedImage

            // Save the loaded image to disk
            saveImageToDisk(image: loadedImage)
        }
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

