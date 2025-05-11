//
//  EditorView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI
import PencilKit
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct EditorView: View {
    @StateObject var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(image: UIImage) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(image: image))
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    Image(uiImage: viewModel.workingImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(viewModel.transformSettings.scale)
                        .rotationEffect(.degrees(viewModel.transformSettings.rotation))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                    DrawingCanvas(canvasView: $viewModel.canvasView)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .allowsHitTesting(viewModel.selectedTool == .draw)

                    if !viewModel.textSettings.content.isEmpty {
                        Text(viewModel.textSettings.content)
                            .font(.system(size: viewModel.textSettings.size))
                            .foregroundColor(viewModel.textSettings.color)
                            .padding(6)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                            .position(viewModel.textSettings.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if viewModel.selectedTool == .text {
                                            viewModel.textSettings.position = value.location
                                        }
                                    }
                            )
                    }
                }
                .clipped()
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .padding(.vertical)

            // Инструменты
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EditorTool.allCases, id: \.self) { tool in
                        Button(tool.rawValue) {
                            viewModel.selectedTool = tool
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(viewModel.selectedTool == tool ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            VStack(spacing: 16) {
                switch viewModel.selectedTool {
                case .transform:
                    VStack {
                        Text("Масштабирование и Поворот")
                            .font(.headline)
                        Slider(value: $viewModel.transformSettings.scale, in: 0.5...2)
                        Slider(value: $viewModel.transformSettings.rotation, in: 0...360)
                    }
                    .padding()

                case .draw:
                    VStack {
                        ColorPicker("Цвет пера", selection: Binding(
                            get: { Color(viewModel.drawingSettings.color) },
                            set: { newColor in
                                viewModel.drawingSettings.color = UIColor(newColor)
                                viewModel.updateDrawingTool()
                            }
                        ))
                        Slider(value: $viewModel.drawingSettings.lineWidth, in: 1...15, step: 1) {
                            Text("Толщина линии")
                        }
                        .onChange(of: viewModel.drawingSettings.lineWidth) {
                            viewModel.updateDrawingTool()
                        }
                    }
                    .padding()

                case .text:
                    VStack {
                        TextField("Введите текст", text: $viewModel.textSettings.content)
                            .textFieldStyle(.roundedBorder)
                        ColorPicker("Цвет текста", selection: $viewModel.textSettings.color)
                        Slider(value: $viewModel.textSettings.size, in: 10...60, step: 1) {
                            Text("Размер текста")
                        }
                    }
                    .padding()

                case .filters:
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.resetImage()
                        }) {
                            VStack {
                                Image(uiImage: viewModel.originalImage)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                Text("Оригинал")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        if let sepiaPreview = viewModel.generateFilterPreview(type: .sepia) {
                            Button(action: {
                                viewModel.applySepia()
                            }) {
                                VStack {
                                    Image(uiImage: sepiaPreview)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                    Text("Сепия")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        if let invertPreview = viewModel.generateFilterPreview(type: .invert) {
                            Button(action: {
                                viewModel.applyInvert()
                            }) {
                                VStack {
                                    Image(uiImage: invertPreview)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                    Text("Инверт")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: 220)

            Spacer()
            HStack(spacing: 16) {
                Button("Сохранить") {
                    viewModel.saveImage()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Поделиться") {
                    viewModel.showShareSheet = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ActivityView(items: [viewModel.renderFinalImage()])
        }
        .navigationTitle("Редактирование")
        .onChange(of: viewModel.shouldDismissEditor) {
            if viewModel.shouldDismissEditor {
                dismiss()
            }
        }
    }
}
