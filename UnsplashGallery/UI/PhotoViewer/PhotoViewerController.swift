//
//  PhotoViewerController.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

protocol PhotoViewerDisplayLogic: AnyObject {
    func displayError(_ error: Error)
    func close()
}

final class PhotoViewerController: UIViewController {
    var viewModel: PhotoViewerViewModelProtocol
    
    private var needStatusBarToBeHidden: Bool = true
    
    private var viewerView: PhotoViewerView {
        return view as! PhotoViewerView
    }
    
    private lazy var dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        gesture.direction = .down
        return gesture
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    override var prefersStatusBarHidden: Bool { return needStatusBarToBeHidden && !UIDevice.current.hasNotch }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    init(viewModel: PhotoViewerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = PhotoViewerView()
        viewerView.dataSource = self
        viewerView.delegate = self
        view.addGestureRecognizer(dismissGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewerView.currentIndex = self.viewModel.preselectedIndex
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideStatusBar(true)
    }
    
    @objc
    func swipeDown() {
        dismiss(animated: true)
    }
}

extension PhotoViewerController: PhotoViewerDisplayLogic {
    func displayError(_ error: Error) {
        // TODO: display error state
    }
    
    func close() {
        dismiss(animated: true)
    }
    
    func hideStatusBar(_ isHidden: Bool) {
        needStatusBarToBeHidden = isHidden
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension PhotoViewerController: PhotoViewerViewDataSource {
    func numberOfItems() -> Int {
        return viewModel.unsplashPhotos.count
    }
    
    func itemAt(_ index: Int) -> UnsplashPhoto? {
        return viewModel.unsplashPhotos[safe: index]
    }
}

extension PhotoViewerController: PhotoViewerViewDelegate {
    func photoViewerViewCanBeClosed(_ view: PhotoViewerView) {
        dismiss(animated: true)
    }
}
