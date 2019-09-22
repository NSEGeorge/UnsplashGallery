//
//  PhotoViewerListViewModel.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

class PhotoViewerListViewModel: PhotoViewerViewModelProtocol {
    weak var controller: PhotoViewerDisplayLogic?
    
    var unsplashPhotos: [UnsplashPhoto]
    var preselectedIndex: Int
    
    init(unsplashPhotos: [UnsplashPhoto], preselectedIndex: Int) {
        self.unsplashPhotos = unsplashPhotos
        self.preselectedIndex = preselectedIndex
    }
}

final class PhotoViewerBuilder {
    private var unsplashPhotos: [UnsplashPhoto]?
    private var preselectedIndex: Int?

    func setUnsplashPhotos(_ unsplashPhotos: [UnsplashPhoto]) -> PhotoViewerBuilder {
        self.unsplashPhotos = unsplashPhotos
        return self
    }
    
    func setPreselectedIndex(_ preselectedIndex: Int) -> PhotoViewerBuilder {
        self.preselectedIndex = preselectedIndex
        return self
    }
    
    func build() -> PhotoViewerController {
        guard let unsplashPhotos = self.unsplashPhotos else {
            preconditionFailure("You must set unsplashPhotos before calling build()")
        }
        guard let preselectedIndex = self.preselectedIndex else {
            preconditionFailure("You must set viewModel before calling build()")
        }
        
        let viewModel = PhotoViewerListViewModel(unsplashPhotos: unsplashPhotos, preselectedIndex: preselectedIndex)
        
        let controller = PhotoViewerController(viewModel: viewModel)
        viewModel.controller = controller
        return controller
    }
}
