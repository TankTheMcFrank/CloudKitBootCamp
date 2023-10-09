//
//  ViewModifierBootcamp.swift
//  CloudKitBootCamp
//
//  Created by Frank Herring on 10/8/23.
//

import SwiftUI

struct DefaultButtonViewModifier: ViewModifier {
    
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
        /* sometimes .font doesn't work well with all views, so maybe leave it in the body below*/
//            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 10)
    }
    
}

extension View {
    
    func withDefaultButtonFormatting(backgroundColor: Color = .blue) -> some View {
        modifier(DefaultButtonViewModifier(backgroundColor: backgroundColor))
    }
    
}

struct ViewModifierBootcampView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .font(.headline)
//                .modifier(DefaultButtonViewModifier())
                .withDefaultButtonFormatting(backgroundColor: .orange)
            
            Text("Hello, Everyone!")
                .font(.subheadline)
//                .modifier(DefaultButtonViewModifier())
                .withDefaultButtonFormatting()
            
            Text("Hello!")
                .font(.title)
//                .modifier(DefaultButtonViewModifier())
                .withDefaultButtonFormatting(backgroundColor: .pink)
        }
        .padding()
    }
}

#Preview {
    ViewModifierBootcampView()
}
