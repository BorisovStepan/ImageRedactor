//
//  MainView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            Spacer()

            Text("Добро пожаловать!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Главная")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Выйти") {
                    viewModel.signOut()
                }
                .foregroundColor(.red)
            }
        }
    }
}
