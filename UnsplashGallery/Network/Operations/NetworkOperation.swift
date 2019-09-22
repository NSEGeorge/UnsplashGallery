//
//  NetworkOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

class NetworkOperation: AsyncOperation {
    
    var endpoint: String { return "" }
    
    private var method: NetworkOperation.Method { return .get }
    private var timeoutInterval = 30.0
    private var task: URLSessionDataTask?
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureCodes: CountableRange<Int> = 400..<499
    
    func prepareURLComponents() -> URLComponents? {
        return URLComponents()
    }

    func prepareParameters() -> [String: Any]? {
        return nil
    }

    func prepareHeaders() -> [String: String]? {
        return nil
    }
    
    func prepareURLRequest() throws -> URLRequest {
        let parameters = prepareParameters()

        guard let url = prepareURLComponents()?.url else {
            throw RequestError.invalidURL
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.query = queryParameters(parameters)
        return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
    }
    
    override func main() {
        
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))
        
        guard var request = try? prepareURLRequest() else {
            finish(with: RequestError.invalidURL)
            return
        }

        request.allHTTPHeaderFields = prepareHeaders()
        request.httpMethod = method.rawValue

        let session = URLSession.shared
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.processResponse(response, data: data, error: error)
        })
        task?.resume()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    func processResponseData(_ data: Data?) {
        super.completed()
    }
}

private extension NetworkOperation {
    func queryParameters(_ parameters: [String: Any]?, urlEncoded: Bool = false) -> String {
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: ".-_")

        var query = ""
        parameters?.forEach { key, value in
            let encodedValue: String
            if let value = value as? String {
                encodedValue = urlEncoded ? value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "" : value
            } else {
                encodedValue = "\(value)"
            }
            query = "\(query)\(key)=\(encodedValue)&"
        }
        return query
    }
    
    func processResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        if let error = error {
            return finish(with: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return finish(with: RequestError.noHTTPResponse)
        }

        processHTTPResponse(httpResponse, data: data)
    }

    func processHTTPResponse(_ response: HTTPURLResponse, data: Data?) {
        let statusCode = response.statusCode

        if successCodes.contains(statusCode) {
            processResponseData(data)
        } else if failureCodes.contains(statusCode) {
            if let data = data, let responseBody = try? JSONSerialization.jsonObject(with: data, options: []) {
                debugPrint(responseBody)
            }
            finish(with: RequestError.http(status: statusCode))
        } else {
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoing mapping or backend bug."
            ]
            let error = NSError(domain: "NetworkOperation", code: 0, userInfo: info)
            finish(with: error)
        }
    }
}

extension NetworkOperation {
    enum Method: String {
        case get, post
    }
    
    enum RequestError: Error {
        case invalidURL
        case noHTTPResponse
        case http(status: Int)

        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .noHTTPResponse:
                return "Not a HTTP response."
            case .http(let status):
                return "HTTP error: \(status)."
            }
        }
    }
}
