//
//  PersonText.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 20.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct PersonText: View {
    
    @State
    var person: Person
    
    var body: some View {
        Text(person.name)
            .padding(2)
            .background(colorOfPerson(person))
            .foregroundColor(Color.white)
            .cornerRadius(5)
            .fixedSize(horizontal: true, vertical: true)
    }
    
    func colorOfPerson(_ person: Person) -> Color {
        guard let color = person.color else {
                return Color.standardColorById(id: person.id)
        }
        
        return Color(color)
    }
}

struct PersonText_Previews: PreviewProvider {
    static var previews: some View {
        PersonText(person: previewPerson)
    }
}
