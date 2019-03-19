//  Swift.map Demo
//  Created by Maciej Matuszewski.

import Foundation

class FeedItem: Codable {
    
    private struct Urls: Codable {
        let raw: String
        let full: String?
        let regular: String
        let small: String?
        let thumb: String?
    }
    
    let id: String
    let description: String?
    private let urls: Urls
    
    var imageURL: String {
        return urls.regular
    }
}

extension FeedItem: Equatable {
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        return lhs.id == rhs.id
    }
}

//extension FeedItem: CustomDebugStringConvertible {
//    var debugDescription: String {
//        return "Feed item with id:\(id) and image url: \(imageURL)"
//    }
//}
