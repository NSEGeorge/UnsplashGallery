//
//  PhotoViewerViewModelProtocol.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

protocol PhotoViewerViewModelProtocol {
    var controller: PhotoViewerDisplayLogic? { get set }
    var unsplashPhotos: [UnsplashPhoto] { get set }
    var preselectedIndex: Int { get set }
}
