//
// Copyright (C) 2017 Tootbot Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Alamofire
import ReactiveSwift

class ImageCacheController {

    enum Error: Swift.Error {
        case downloadFailed(Swift.Error?)
        case writeToFileFailed(Swift.Error?)
    }

    private static let memoryCache = NSCache<NSString, UIImage>()
    private static let cacheDirectoryURL: URL = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath)
        return url.appendingPathComponent("ImageCache")
    }()

    private let fileManager = FileManager.default

    init() {
        if fileManager.fileExists(atPath: ImageCacheController.cacheDirectoryURL.path) == false {
            try? fileManager.createDirectory(at: ImageCacheController.cacheDirectoryURL,
                                        withIntermediateDirectories: true)
        }
    }

    public func fetch(url: URL) -> SignalProducer<UIImage, Error> {
        let key = self.key(for: url)
        return downloadImage(from: url)
            .take(untilReplacement: fetchImageFromDisk(with: key))
            .take(untilReplacement: fetchImageFromMemory(with: key))
    }

    private func key(for url: URL) -> String {
        return String(url.hashValue)
    }

    private func fetchImageFromMemory(with key: String) -> SignalProducer<UIImage, Error> {
        return SignalProducer { observer, disposable in
            if let image = ImageCacheController.memoryCache.object(forKey: key as NSString) {
                observer.send(value: image)
            }
        }
    }

    private func fetchImageFromDisk(with key: String) -> SignalProducer<UIImage, Error> {
        return SignalProducer { observer, disposable in
            let url = self.localURLForKey(key: key)
            if self.fileManager.fileExists(atPath: url.path), let image = UIImage(contentsOfFile: url.path) {
                observer.send(value: image)
            }
        }
    }

    private func localURLForKey(key: String) -> URL {
        return ImageCacheController.cacheDirectoryURL.appendingPathComponent(key)
    }

    private func store(image: UIImage, with key: String) throws {
        ImageCacheController.memoryCache.setObject(image, forKey: key as NSString)

        let url = localURLForKey(key: key)
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }

        do {
            try data.write(to: url)
        } catch {
            throw Error.writeToFileFailed(error)
        }
    }

    private func downloadImage(from url: URL) -> SignalProducer<UIImage, Error> {
        return SignalProducer { observer, disposable in
            Alamofire.request(url).responseData { response in
                guard let data = response.data else {
                    observer.send(error: .downloadFailed(response.error))
                    return
                }

                guard let image = UIImage(data: data) else {
                    return
                }

                observer.send(value: image)
                do {
                    try self.store(image: image, with: self.key(for: url))
                } catch let error as Error {
                    observer.send(error: error)
                } catch {
                    print("Unknown error")
                }
            }
        }
    }

}
