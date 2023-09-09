//
//  GoogleBooksAPI.swift
//  Bookorm
//
//  Created by Mohana Danthuluru on 4/4/23.
//

import Foundation

class GoogleBooksAPI {
    private let apiKey = "AIzaSyBtMNbQeN4QYNDfdbc6ezEC_fxQnkabJSU"
    private let baseURL = "https://www.googleapis.com/books/v1"

    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        let searchURL = "\(baseURL)/volumes?q=\(query)&key=\(apiKey)"
        let encodedURL = searchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encodedURL!) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let items = json["items"] as! [[String: AnyObject]]
                let books = items.compactMap { item -> Book? in
                    let volumeInfo = item["volumeInfo"] as! [String: AnyObject]
                    let id = item["id"] as! String
                    let title = volumeInfo["title"] as! String
                    let authors = volumeInfo["authors"] as? [String] ?? []
                    let description = volumeInfo["description"] as? String

                    let thumbnailURL: URL? = {
                        guard let imageLinks = volumeInfo["imageLinks"] as? [String: AnyObject],
                              let thumbnail = imageLinks["thumbnail"] as? String else {
                            return nil
                        }
                        return URL(string: thumbnail)
                    }()

                    return Book(id: id, title: title, authors: authors, description: description, thumbnailURL: thumbnailURL)
                }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
