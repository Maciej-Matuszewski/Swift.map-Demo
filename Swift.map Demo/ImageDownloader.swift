//  Swift.map Demo
//  Created by Maciej Matuszewski.

import Foundation
import UIKit

class ImageDownloader {
    private var cache = NSCache<AnyObject, AnyObject>()
    
    func image(from urlString: String, completion:@escaping (_ image: UIImage?) -> ()) {
        if let data = cache.object(forKey: urlString as AnyObject) as? Data {
            let image = UIImage(data: data)
            DispatchQueue.main.async { completion(image) }
            return
        }
        
        guard let url = URL(string: urlString) else { return completion(nil) }
        let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let image = UIImage.init(data: data)
            self.cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
            DispatchQueue.main.async { completion(image) }
        }
        downloadTask.resume()
    }
}
