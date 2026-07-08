//
//  SearchField.swift
//  RecipeAppUI
//
//  Created by Elyura on 15.03.26.
//

import SwiftUI

struct SearchField: View {
    @Binding var text: String
    @State private var placeHolder = LocalizedStringKey("Search")
        
    @FocusState private var isFocused: Bool
    
   
    var body: some View {
        HStack(spacing: 8){
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.appSecondaryText)
                .padding(.leading, 16)
            TextField(placeHolder, text: $text)
                .focused($isFocused)
                .padding(19)
                
            
            if !text.isEmpty {
                Button{
                    text = ""
                }label:{
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        .background(.black,in: Circle())
                        .padding(5)
                    
                }
            }
        }
      
        .background(.appForm)
        .clipShape(.capsule)
    }
}

#Preview {
    @Previewable @State var text: String = ""
    SearchField(text: $text)
}
