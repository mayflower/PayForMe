//
//  AddMemberView.swift
//  PayForMe
//
//  Created by Camille Mainz on 04.03.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct AddMemberView: View {
    
    @Binding
    var memberName: String
    
    var addMemberAction: () -> ()
    var cancelButtonAction: () -> ()
   
    var cancelButtonWidth: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                EmptyView()
                Spacer()
                Text("Add Member")
                .font(.headline)
                .multilineTextAlignment(.center)
                    .padding(.trailing, -cancelButtonWidth)
                Spacer()
                Button(action: cancelButtonAction, label: { Image(systemName: "xmark.circle.fill") })
                    .frame(width: cancelButtonWidth, height: cancelButtonWidth, alignment: .center)
            }
            TextField("Member Name", text: $memberName)
                .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            FancyButton(isDisabled: .constant(false), isLoading: .constant(false), add: false, action: addMemberAction, text: "Submit")
        }
        .padding()
    }

}

struct AddMemberView_Previews: PreviewProvider {
    static var previews: some View {
        AddMemberView(memberName: .constant("Lel"), addMemberAction: {}, cancelButtonAction: {})
    }
}
