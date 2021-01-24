//
//  APIClient.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    func requestObject<T: Decodable>(router: APIRouter, completion: (@escaping (_: Result<T, Error>) -> Void)) {
        guard let request = router.asURLRequest() else {
            completion(Result.failure(AppError.generic))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(Result.failure(error))
                return
            }
          
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completion(Result.failure(AppError.generic))
                return
            }

            if let data = data,
            let result = try? JSONDecoder().decode(T.self, from: data) {
                completion(Result.success(result))
            }
        })
        task.resume()
    }
}
