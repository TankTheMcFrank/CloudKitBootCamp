//
//  ButtonStyleBootcamp.swift
//  CloudKitBootCamp
//
//  Created by Frank Herring on 10/9/23.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    
    let scaledAmount: CGFloat
    
    init(scaledAmount: CGFloat = 0.9) {
        self.scaledAmount = scaledAmount
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaledAmount : 1.0)
//            .brightness(configuration.isPressed ? 0.1 : 0.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
    
}

extension View {
    
    func withPressableStyle(scaledAmount: CGFloat = 0.9) -> some View {
        buttonStyle(PressableButtonStyle(scaledAmount: scaledAmount))
    }
    
}

struct ButtonStyleBootcamp: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Click Me")
                .font(.headline)
                .withDefaultButtonFormatting()
        }
        .withPressableStyle(scaledAmount: 1.2)
//        .buttonStyle(PressableButtonStyle())
        .padding(40)

    }
}

#Preview {
    ButtonStyleBootcamp()
}
