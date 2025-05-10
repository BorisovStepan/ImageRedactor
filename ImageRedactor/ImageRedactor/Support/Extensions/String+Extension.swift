//
//  String+Extension.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Foundation

extension String {
    static var empty = ""
}

extension String {
    var isNotEmpty: Bool {
         return !self.isEmpty
     }
}
