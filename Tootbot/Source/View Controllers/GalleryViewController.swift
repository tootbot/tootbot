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

import PINRemoteImage
import Spyglass
import UIKit
import XKPhotoScrollView

class GalleryViewController: UIViewController, SpyglassTransitionDestination, SpyglassTransitionSource, XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate {
    var prefetchingUUIDs = [IndexPath: UUID]()
    var photoScrollView: XKPhotoScrollView!
    let viewModel: AttachmentsViewModel
    private let initialIndex: Int

    deinit {
        prefetchingUUIDs.values.forEach(PINRemoteImageManager.shared().cancelTask)
    }

    init(viewModel: AttachmentsViewModel, initialIndex: Int = 0) {
        self.viewModel = viewModel
        self.initialIndex = initialIndex
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func done(_ sender: AnyObject?) {
        dismiss(animated: true)
    }

    func updateNavigationItemTitle(index: Int) {
        navigationItem.title = String(format: NSLocalizedString("Item %d of %d", comment: ""), index + 1, viewModel.attachments.count)
    }

    func configureNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        updateNavigationItemTitle(index: 0)
    }

    func configurePhotoScrollView() {
        let photoScrollView = XKPhotoScrollView(frame: view.bounds)
        photoScrollView.autoresizingMask = .flexibleSize
        photoScrollView.dataSource = self
        photoScrollView.delegate = self
        photoScrollView.setCurrentIndexPath(IndexPath(row: 0, col: initialIndex), animated: false)
        view.addSubview(photoScrollView)
        self.photoScrollView = photoScrollView
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1725490196, blue: 0.2156862745, alpha: 1)

        configurePhotoScrollView()
        configureNavigationItem()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Photo Scroll View

    func photoScrollViewCols(_ photoScrollView: XKPhotoScrollView) -> UInt {
        return UInt(viewModel.attachments.count)
    }

    func photoScrollView(_ photoScrollView: XKPhotoScrollView, requestViewAt indexPath: IndexPath) {
        let attachment = viewModel.attachments[indexPath.col]
        if attachment.isImage {
            guard prefetchingUUIDs[indexPath] == nil else { return }
            prefetchingUUIDs[indexPath] = PINRemoteImageManager.shared().downloadImage(with: [attachment.previewURL, attachment.fullSizeURL], progressImage: nil, completion: { result in
                DispatchQueue.main.async {
                    self.prefetchingUUIDs[indexPath] = nil

                    if let image = result.image {
                        let imageView = UIImageView(image: image)
                        photoScrollView.setView(imageView, at: indexPath, placeholder: false)
                    }
                }
            })
        } else {
            let videoPlayer = VideoPlayerView(frame: view.bounds)
            videoPlayer.configure(with: attachment.fullSizeURL)
            photoScrollView.setView(videoPlayer, at: indexPath, placeholder: false)
        }
    }

    func photoScrollView(_ photoScrollView: XKPhotoScrollView, cancelRequestAt indexPath: IndexPath) {
        if let uuid = prefetchingUUIDs.removeValue(forKey: indexPath) {
            PINRemoteImageManager.shared().cancelTask(with: uuid)
        }
    }

    func photoScrollView(_ photoScrollView: XKPhotoScrollView, didTap view: UIView, at pt: CGPoint, at indexPath: IndexPath) {
        guard let navigationController = navigationController else { return }
        navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
    }

    func photoScrollView(_ photoScrollView: XKPhotoScrollView, didChangeTo indexPath: IndexPath) {
        updateNavigationItemTitle(index: indexPath.col)
    }

    // MARK: - Spyglass

    func userInfo(for transitionType: SpyglassTransitionType, from initialViewController: UIViewController, to finalViewController: UIViewController) -> SpyglassUserInfo? {
        return [
            SpyglassUserInfoKey.index: photoScrollView.currentIndexPath.col
        ]
    }
    
    func sourceSnapshotView(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> UIView {
        let index = userInfo![SpyglassUserInfoKey.index] as! Int
        let attachment = viewModel.attachments[index]

        let imageView = UIImageView()
        imageView.pin_setImage(from: attachment.previewURL)
        return imageView
    }

    func sourceRect(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> SpyglassRelativeRect {
        return SpyglassRelativeRect(view: photoScrollView.currentView)
    }

    func sourceTransitionWillBegin(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?) {
        photoScrollView.isHidden = true
    }

    func sourceTransitionDidEnd(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?, completed: Bool) {
        photoScrollView.isHidden = false
    }

    func destinationSnapshotView(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> UIView {
        let index = userInfo![SpyglassUserInfoKey.index] as! Int
        let attachment = viewModel.attachments[index]

        let imageView = UIImageView()
        imageView.pin_setImage(from: attachment.previewURL)
        return imageView
    }

    func destinationRect(for transitionType: SpyglassTransitionType, userInfo: SpyglassUserInfo?) -> SpyglassRelativeRect {
        return SpyglassRelativeRect(rect: photoScrollView.viewFrame, relativeTo: photoScrollView)
    }

    func destinationTransitionWillBegin(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?) {
        photoScrollView.isHidden = true
    }

    func destinationTransitionDidEnd(for transitionType: SpyglassTransitionType, viewController: UIViewController, userInfo: SpyglassUserInfo?, completed: Bool) {
        photoScrollView.isHidden = false
    }
}
