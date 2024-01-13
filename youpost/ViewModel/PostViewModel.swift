//
//  PostViewModel.swift
//  youpost
//
//  Created by Benjamin. on 13/01/2024.
//

import Foundation

enum PostState{
    case initial
    case loading
    case error
}

class PostViewModel: ObservableObject {
    
    @Published var posts = [PostModel]()
    @Published var errMsg = ""
    @Published var state: PostState = .initial
    private var service: PostService
    
    init(service: PostService){
        self.service = service
        Task{
            do {
                self.state = .loading
                let data = try await service.getAllPosts()
                DispatchQueue.main.async {
                    self.posts = data
                    self.state = .initial
                }
            } catch let error as PostError{
                DispatchQueue.main.async {
                    self.state = . error
                    self.errMsg = error.description
                }
            }
            
        }
    }
    
    //update Post
    func updatePost(_ id:Int, title:String, content:String) {
        self.state = .loading
        
        if let index = posts.firstIndex(where: {$0.id == id}) {
            
            var post = posts[index]
            post.content = content
            post.title = title
            
            self.posts[index] = post
            self.state = .initial
        }
        
    }
    
    //delete Post
    func delPost(_ id:Int){
        self.state = .loading
        if let index = posts.firstIndex(where: {$0.id == id}) {
            self.posts.remove(at: index)
            self.state = .initial
        }
    }
}
