//
//  PostModel.swift
//  youpost
//
//  Created by Benjamin. on 13/01/2024.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let postData = try? JSONDecoder().decode(PostData.self, from: jsonData)

import Foundation

// MARK: - PostData
struct PostData: Codable {
    var status: Int
    var message: String
    var data: [PostModel]
}

// MARK: - PostModel
struct PostModel: Codable, Identifiable, Hashable {
    var id: Int
    var title, content: String
    var image: String
    var createdAt: String
    var formattedDate:Date {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: self.createdAt) else{
            return Date()
        }
        return date
    }
}


class PostService {
    static let shared = PostService()
    private var baseURL = "http://127.0.0.1:9090"
    
    //get All Posts
    func getAllPosts() async throws -> [PostModel] {
        
        do{
            guard let url = URL(string: "\(baseURL)/posts") else {
                throw PostError.requestError(des: "Issue with the url")
            }
            let (data, res) = try await URLSession.shared.data(from: url)
            guard let res = res as? HTTPURLResponse else{
                throw PostError.requestError(des: "Could not get response")
            }
            if res.statusCode != 200 {
                let pErrorData = try JSONDecoder().decode(PostErrorModel.self, from: data)
                throw PostError.requestError(des: pErrorData.message)
            }
            let posts = try JSONDecoder().decode(PostData.self, from: data)
            
            return posts.data
        } catch {
            throw PostError.unknownError(error: error)
        }
    }
}

struct PostErrorModel: Codable {
    let status: Int
    let message: String
}

enum PostError: Error {
    case unknownError(error: Error)
    case parseError
    case requestError(des:String)
    case invalidStatus(status: Int)
    
    var description: String {
        switch self {
        case let .requestError(des): return "Request error: \(des)"
        case let .invalidStatus(status): return "Invalid response status: \(status)"
        case .parseError: return "Error while parsing JSON to Model"
        case let .unknownError(error): return "Unknown error: \(error.localizedDescription)"
        }
    }
}
