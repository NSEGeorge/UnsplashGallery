//
//  PopularPhotosProvider.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

protocol PopularPhotosProviderDelegate: AnyObject {
    func providerWillStartFetching(_ provider: PopularPhotosProvider)
    func provider(_ provider: PopularPhotosProvider, didFetch items: [UnsplashPhoto])
    func provider(_ provider: PopularPhotosProvider, fetchDidFailWithError error: Error)
}

extension PopularPhotosProvider {
    static let initialPageObject = PagingOperation.PageObject(page: 1, perPage: 30)
}

class PopularPhotosProvider {
    var items: [UnsplashPhoto] = []
    
    weak var delegate: PopularPhotosProviderDelegate?
    
    var canFetchMore: Bool = false
    
    private lazy var operationQueue = OperationQueue(with: "com.unsplash.PopularPhotosDataSource")
    private let factory = OperationsFactory()
    private var pageObject: PagingOperation.PageObject
    
    private var isFetching: Bool = false
    private var isRefreshing: Bool = false
    
    init() {
        pageObject = PopularPhotosProvider.initialPageObject
    }
    
    func fetchNextPage() {
        isRefreshing = false
        fetch()
    }
    
    func refresh() {
        pageObject = PopularPhotosProvider.initialPageObject
        isRefreshing = true
        fetch()
    }
    
    private func fetch() {
        let operation = factory.popularOperation(with: self.pageObject)
        operation.getPopularPhotosCompletion = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                self.isFetching = false
                self.fetchDidComplete(withItems: items, error: nil)
                
                if items.count < self.pageObject.perPage {
                    self.canFetchMore = false
                } else {
                    self.canFetchMore = true
                    self.pageObject = operation.nextPage()
                }
                
                if self.isRefreshing {
                    self.items = []
                }
                self.items.append(contentsOf: items)
                
            case .failure(let error):
                self.isFetching = false
                self.fetchDidComplete(withItems: nil, error: error)
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    private func fetchDidComplete(withItems items: [UnsplashPhoto]?, error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.provider(self, fetchDidFailWithError: error)
            }
        } else {
            let items = items ?? []
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.provider(self, didFetch: items)
            }
        }
    }
}
