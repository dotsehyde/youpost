//
//  ContentView.swift
//  youpost
//
//  Created by Benjamin. on 12/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var list = [1,2,3,4,5,6,7,8,9]
    @State private var newPost = false
    @EnvironmentObject var viewModel:PostViewModel
    // MARK: - Search
 var searchList: [PostModel] {
        guard !searchText.isEmpty else{
            return viewModel.posts
        }
     return viewModel.posts.filter { $0.title.contains(searchText)}
    }
    var body: some View {
        NavigationStack{
            List{
                ForEach(viewModel.posts, id:\.self ){data in
                    HStack(alignment: .center, spacing: 8) {
                        AsyncImage(url: URL(string: data.image)) { img in
                            img
                                .resizable()
                        } placeholder: {
                            Color(.systemGray4)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("Hello, world!")
                                .lineLimit(1)
                                .font(.headline)
                            Text(data.content)
                                .lineLimit(2)
                                .foregroundStyle(.secondary)
                            Text(data.formattedDate.formatted())
                        }
                    }
                    .font(.footnote)
                }
               
                .onMove { list.move(fromOffsets: $0, toOffset: $1) }
                .onDelete {
                    list.remove(atOffsets: $0)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .keyboardType(.numberPad)
            .overlay{
                if(viewModel.state == .loading){
                    ZStack{
                        Color(.white)
                            .ignoresSafeArea()
                        ProgressView {
                            Text("Loading...")
                        }
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.blue)
                            
                    }
                    
                    
                }
            }
            .navigationTitle("YouPost")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                                            EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            // MARK: - New Post
            .sheet(isPresented: $newPost) {
                VStack {
                    NewPostView(hide: $newPost)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PostViewModel(service: PostService.shared))
    }
}
