//
//  NPSPromptView.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import SwiftUI

struct NPSPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: DebtorStore

    @State private var score: Int = 8

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Оцените приложение")
                        .font(.title2).bold()
                    Text("Насколько вероятно, что вы порекомендуете Debtors знакомым?")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    Slider(value: Binding(get: { Double(score) }, set: { score = Int($0.rounded()) }),
                           in: 0...10, step: 1)
                    HStack {
                        Text("0")
                        Spacer()
                        Text("\(score)")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                        Text("10")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))

                VStack(spacing: 10) {
                    Button {
                        FeedbackManager.shared.submitNPS(score: score)
                        dismiss()
                    } label: {
                        Text("Отправить")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Не сейчас")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Обратная связь")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
