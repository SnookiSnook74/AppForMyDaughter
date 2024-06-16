//
//  ViewController.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import SwiftUI


struct StartView: View {
    @EnvironmentObject private var viewModel:StartViewModel

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField("Enter your question...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 40)
                
                Button("Send") {
                    viewModel.sendButtonTapped()
                }
                .frame(width: 60, height: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.green.ignoresSafeArea())
    }
}
