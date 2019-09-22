//
//  RandomPhotosProvider.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

protocol RandomPhotosProviderDelegate: AnyObject {
    func providerWillStartFetching(_ provider: RandomPhotosProvider)
    func provider(_ provider: RandomPhotosProvider, didFetch items: [UnsplashPhoto])
    func provider(_ provider: RandomPhotosProvider, fetchDidFailWithError error: Error)
}

extension RandomPhotosProvider {
    static let initialPageObject = PagingOperation.PageObject(page: 1, perPage: 30)
}

class RandomPhotosProvider {
    var items: [UnsplashPhoto] = []
    
    weak var delegate: RandomPhotosProviderDelegate?
    
    private lazy var operationQueue = OperationQueue(with: "com.unsplash.RandomPhotosDataSource")
    private let factory = OperationsFactory()
    private var pageObject: PagingOperation.PageObject
    
    private var isFetching: Bool = false
    private var canFetchMore: Bool = false
    private var isRefreshing: Bool = false
    
    init() {
        pageObject = RandomPhotosProvider.initialPageObject
    }
    
    func fetchNextPage() {
        isRefreshing = false
        fetch()
    }
    
    func refresh() {
        pageObject = RandomPhotosProvider.initialPageObject
        isRefreshing = true
        fetch()
    }
    
    private func fetch() {
        guard !isFetching else { return }
        let operation = factory.randomOperation(with: self.pageObject)
        operation.getRandomPhotosCompletion = { [weak self] result in
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
        
        isFetching = true
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
