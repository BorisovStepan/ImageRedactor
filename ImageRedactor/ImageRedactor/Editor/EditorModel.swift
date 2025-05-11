//
//  EditorModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import Foundation
import Foundation
import SwiftUI

enum EditorTool: String, CaseIterable, Identifiable {
    case transform = "Поворот/Масштаб"
    case draw = "Рисование"
    case text = "Текст"
    case filters = "Фильтры"

    var id: String { self.rawValue }
}

struct EditableText {
    var content: String = ""
    var color: Color = .white
    var size: CGFloat = 24
    var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 150)
}

struct DrawingSettings {
    var color: UIColor = .black
    var lineWidth: CGFloat = 5
}

struct TransformSettings {
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0
}

enum PreviewFilterType {
    case sepia
    case invert
}
