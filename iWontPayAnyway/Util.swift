//
//  Util.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 28.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import SwiftUI

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    init(_ pc: PersonColor) {
        self.init(red: Double(pc.r)/255, green: Double(pc.g)/255, blue: Double(pc.b)/255, opacity: 1)
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return (match.range.length == self.utf16.count) && (self.contains("https://") || self.contains("http://"))
        }
        return false
    }
}

extension JSONDecoder {
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
}

extension JSONEncoder {
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateEncodingStrategy = .formatted(dateFormatter)
    }
}

extension DateFormatter {
    static let cospend: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
}

struct TextFieldContainer: UIViewRepresentable {
    private var placeholder : String
    private var text : Binding<String>
    
    init(_ placeholder:String, text:Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    func makeCoordinator() -> TextFieldContainer.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<TextFieldContainer>) -> UITextField {
        
        let innertTextField = UITextField(frame: .zero)
        innertTextField.placeholder = placeholder
        innertTextField.text = text.wrappedValue
        innertTextField.delegate = context.coordinator
        
        context.coordinator.setup(innertTextField)
        
        return innertTextField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldContainer>) {
        uiView.text = self.text.wrappedValue
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldContainer
        
        init(_ textFieldContainer: TextFieldContainer) {
            self.parent = textFieldContainer
        }
        
        func setup(_ textField:UITextField) {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            self.parent.text.wrappedValue = textField.text ?? ""
            
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
}
