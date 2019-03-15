//  Swift.map Demo
//  Created by Maciej Matuszewski.

import Foundation

class FeedRequest: APIRequest {
    
    let page: Int
    
    var path: String {
        return "photos"
    }
    
    var parameters: [String : String] {
        return [
            "page": "\(page)",
            "client_id": "6e33255d49e9e0baeb10eca49722a54f8dfeb52a7a8d99f18fce4115f64cfa37"
        ]
    }
    
    var method: APIClient.HTTPMethod {
        return .GET
    }
    
    init(page: Int = 1) {
        self.page = page
    }
}
