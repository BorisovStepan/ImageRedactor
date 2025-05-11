//
//  MainView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI
import PhotosUI

import SwiftUI
import PhotosUI

private enum Constants {
    static let imagePickerTitle = "Выберите изображение"
    static let imagePickerButtonTitle = "Выбрать фото"
    static let imageRedactorButtonTitle = "Редактировать"
    static let title = "Главная"
    static let exitText = "Выйти"
}

struct MainView: View {
    @StateObject private var viewModel: MainViewModel

    init(router: Router) {
        _viewModel = StateObject(wrappedValue: MainViewModel(router: router))
    }

    var body: some View {
        content
            .navigationTitle(Constants.title)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Constants.exitText) {
                        viewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $viewModel.isEditorOpen) {
                if let image = viewModel.selectedImage {
                    EditorView(image: image)
                }
            }
    }

    private var content: some View {
        VStack(spacing: 20) {
            selectedImageSection
            actionButtons
            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private var selectedImageSection: some View {
        if let image = viewModel.selectedImage {
            GeometryReader { geo in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width)
                    .clipped()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.selectedImage)
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .background(Color.gray.opacity(0.1))
        } else {
            Spacer()
            Text(Constants.imagePickerTitle)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Text(Constants.imagePickerButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ProgressButton(
                title: Constants.imageRedactorButtonTitle,
                backgroundColor: .green,
                textColor: .white,
                isLoading: false,
                isDisabled: viewModel.selectedImage == nil
            ) {
                viewModel.isEditorOpen = true
            }
        }
        .padding(.horizontal)
    }
}
