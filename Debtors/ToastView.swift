//
//  ToastView.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import SwiftUI

struct ToastView: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.white)

            Text(text)
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.85))
        .clipShape(Capsule())
        .shadow(radius: 6)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
