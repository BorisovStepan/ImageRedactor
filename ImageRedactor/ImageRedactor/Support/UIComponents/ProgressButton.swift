//
//  ProgressButton.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI

struct ProgressButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                } else {
                    Text(title)
                        .foregroundColor(isDisabled ? .gray : textColor)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray.opacity(0.3) : backgroundColor)
            .cornerRadius(8)
        }
        .disabled(isLoading || isDisabled)
    }
}
