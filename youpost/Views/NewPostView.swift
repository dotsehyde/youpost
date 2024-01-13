//
//  NewPostView.swift
//  youpost
//
//  Created by Benjamin. on 13/01/2024.
//

import SwiftUI

struct NewPostView: View {
    @Binding var hide: Bool
    @State var title = ""
    @State var content = ""
    @EnvironmentObject var viewModel: PostViewModel
    var body: some View {
        ScrollView{
            VStack (spacing: 10){
                
                HStack{
                    Text("Create a new Post")
                        .font(.title3)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.vertical,10)
                .padding(.horizontal)
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 300, height: 200)
                
                TextField("Post Title",text: $title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1)
                            .fill(Color(.systemGray4))
                    )
                    .padding()
                ZStack(alignment: .topLeading){
                  
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .fill(Color(.systemGray4))
                        )
                        .padding(.horizontal)
                    if content.isEmpty {
                                   Text("Post Content")
                                       .foregroundColor(Color(.placeholderText))
                                       .padding(.horizontal, 35)
                                       .padding(.vertical, 25)
                               }
                }
                Button {
                    hide.toggle()
                } label: {
                    Text("Create Post")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                .padding(.vertical,10)
                Button {
                    hide.toggle()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                      
                }
            
                Spacer()
            }
        }
        
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(hide: .constant(false))
            .environmentObject(PostViewModel(service: PostService.shared))
    }
}
