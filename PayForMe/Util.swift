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
    
    static var PFMBackground: Color {
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            return Color.black
        } else {
            return Color(UIColor(red:0.95, green:0.95, blue:0.97, alpha:1.0))
        }
    }
    
    static func standardColorById(id: Int) -> Color {
        let colors = [
            rgb(88,86,214),
            rgb(52,170,220),
            rgb(90,200,250),
            rgb(76,217,100),
            rgb(255,59,48),
            rgb(255,59,48),
            rgb(255,149,0),
            rgb(255,204,0)
        ]
        return colors[id % colors.count]
    }
    
    private static func rgb(_ r: Int, _ g: Int, _ b: Int) -> Color {
        Color(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0, opacity: 1)
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
        innertTextField.keyboardType = .URL
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
