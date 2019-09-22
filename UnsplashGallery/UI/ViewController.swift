//
//  ViewController.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 17/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    private let randomPhotosProvider: RandomPhotosProvider = .init()
    private let popularPhotosProvider: PopularPhotosProvider = .init()
    
    private var randomPhotosWasFetched: Bool = false
    private var popularPhotosWasFetched: Bool = false
    
    private lazy var gridView: GridView = {
        let view = GridView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.backgroundColor
        title = "Unsplash Gallery"
        configureLayout()
        
        randomPhotosProvider.delegate = self
        popularPhotosProvider.delegate = self
        
        randomPhotosProvider.fetchNextPage()
        popularPhotosProvider.fetchNextPage()
    }
    
    private func tryEndRefreshing() {
        if randomPhotosWasFetched && popularPhotosWasFetched {
            gridView.endRefreshing()
        }
    }
}

extension ViewController: RandomPhotosProviderDelegate {
    func providerWillStartFetching(_ provider: RandomPhotosProvider) {
        // TODO: display loading state
    }
    
    func provider(_ provider: RandomPhotosProvider, didFetch items: [UnsplashPhoto]) {
        randomPhotosWasFetched = true
        gridView.reloadRandomSection()
        tryEndRefreshing()
    }
    
    func provider(_ provider: RandomPhotosProvider, fetchDidFailWithError error: Error) {
        // TODO: display error state
    }
}

extension ViewController: PopularPhotosProviderDelegate {
    func providerWillStartFetching(_ provider: PopularPhotosProvider) {
        // TODO: display loading state
    }
    
    func provider(_ provider: PopularPhotosProvider, didFetch items: [UnsplashPhoto]) {
        popularPhotosWasFetched = true
        gridView.refreshPopularSection()
        tryEndRefreshing()
    }
    
    func provider(_ provider: PopularPhotosProvider, fetchDidFailWithError error: Error) {
        // TODO: display error state
    }
}

extension ViewController: RandomPhotosPreviewDelegate {
    func randomPhotosPreview(_ randomPhotosPreview: RandomPhotosPreview, didSelectPhotoAt index: Int) {
        let builder = PhotoViewerBuilder()
        let ctrl = builder.setUnsplashPhotos(randomPhotosProvider.items)
            .setPreselectedIndex(index)
            .build()
        
        ctrl.modalPresentationStyle = .fullScreen
        
        present(ctrl, animated: true, completion: nil)
    }
}

extension ViewController: RandomPhotosPreviewDataSource {
    func numberOfPhotos(in randomPhotosPreview: RandomPhotosPreview) -> Int {
        return randomPhotosProvider.items.count
    }
    
    func randomPhotosPreview(_ randomPhotosPreview: RandomPhotosPreview, photoAt index: Int) -> UnsplashPhoto? {
        return randomPhotosProvider.items[safe: index]
    }
}

extension ViewController: PopularPhotosDataSource {
    func numberOfPhotos(in gridView: GridView) -> Int {
        return popularPhotosProvider.canFetchMore ? popularPhotosProvider.items.count + 1 : popularPhotosProvider.items.count
    }
    
    func gridView(_ gridView: GridView, photoAt index: Int) -> UnsplashPhoto? {
        return popularPhotosProvider.items[safe: index]
    }
    
    func canLoadNext(in gridView: GridView) -> Bool {
        return popularPhotosProvider.canFetchMore
    }
}

extension ViewController: PopularPhotosDelegate {
    func gridView(_ gridView: GridView, didSelectPhotoAt index: Int) {
        guard let item = popularPhotosProvider.items[safe: index] else { return }
        let builder = PhotoViewerBuilder()
         let ctrl = builder.setUnsplashPhotos([item])
             .setPreselectedIndex(0)
             .build()
         
         ctrl.modalPresentationStyle = .fullScreen
         
         present(ctrl, animated: true, completion: nil)
    }
}

extension ViewController: RefreshingDelegate {
    func refresh() {
        randomPhotosWasFetched = false
        popularPhotosWasFetched = false
        
        popularPhotosProvider.refresh()
        randomPhotosProvider.refresh()
    }
    
    func fetchNextPage() {
        popularPhotosProvider.fetchNextPage()
    }
}

private extension ViewController {
    func configureLayout() {
        self.view.addSubview(gridView)
        NSLayoutConstraint.activate([
            gridView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            gridView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            gridView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            gridView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
