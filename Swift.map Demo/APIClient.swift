//  Swift.map Demo
//  Created by Maciej Matuszewski.

import Foundation

protocol APIRequest {
    var path: String { get }
    var method: APIClient.HTTPMethod { get }
    var parameters: [String : String] { get }
}

extension APIRequest {
    
    var url: URL {
        return URL(string: "https://api.unsplash.com/")!
    }
    
    var urlRequest: URLRequest? {
        guard var components = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: false) else { return nil }
        
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }
}

class APIClient {
    
    enum HTTPMethod: String{
        case GET
        case POST
        case PUT
    }
    
    private let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        return session
    }()
    
    func send<T: Codable>(request: APIRequest, completion: ((T?)->())?) {
        guard let request = request.urlRequest else {
            completion?(nil)
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let models = try? JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.sync {
                completion?(models)
            }
        }
        task.resume()
    }
}
