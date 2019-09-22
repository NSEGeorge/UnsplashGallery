//
//  UnsplashOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

// TODO: Use more secure way
enum ApiConfig {
    static var accessKey: String {
        return "7f7dcc708423aa1593485ca2c9eb32d622142f95b5d672ecba15a53aabc58e91"
    }
    
    static var secretKey: String {
        return "4dcae75d610f262607604390a7cc7ded76a6a12480ee0b077d8ca8ea4497c3bd"
    }
    
    static var baseApiPath: String {
        return "https://api.unsplash.com/"
    }
}

class UnsplashOperation: NetworkOperation {
    
    private(set) var jsonResponse: Any?
    
    override func prepareURLComponents() -> URLComponents? {
        guard let baseApiPath = URL(string: ApiConfig.baseApiPath) else { return nil }

        var urlComponents = URLComponents(url: baseApiPath, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint
        return urlComponents
    }

    override func prepareParameters() -> [String: Any]? {
        return nil
    }

    override func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID \(ApiConfig.accessKey)"
        return headers
    }
    
    override func processResponseData(_ data: Data?) {
        if let error = error {
            finish(with: error)
            return
        }
        guard let data = data else { return }

        do {
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            processJSONResponse()
        } catch {
            finish(with: RequestError.invalidJSONResponse)
        }
    }

    func processJSONResponse() {
        if let error = error {
            finish(with: error)
        } else {
            completed()
        }
    }
}

extension UnsplashOperation {
    enum RequestError: Error {
        case invalidJSONResponse

        var localizedDescription: String {
            switch self {
            case .invalidJSONResponse:
                return "Invalid JSON response."
            }
        }
    }
}
