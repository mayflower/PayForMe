//
//  FloatingAddButtonViewModifier.swift
//  PayForMe
//
//  Created by Max Tharr on 03.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct FloatingAddButtonViewModifier: ViewModifier {
    @State private var sheetToggle = false
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $sheetToggle) {
                AddBillView(showModal: $sheetToggle)
            }
            .overlay( FloatingAddButtonView(sheetToggle: $sheetToggle).padding(32), alignment: .bottom)
    }
}

private struct FloatingAddButtonView: View {
    @Binding var sheetToggle: Bool
    
    var body: some View {
            Button(action: {
                sheetToggle.toggle()
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue)
                    .shadow(color: Color(red: 0.53, green: 0.53, blue: 0.53), radius: 3, x: 2, y: 2)
            }
            .accessibility(identifier: "Add Bill")
            .accessibility(label: Text("Add Bill"))
    }
}

struct FloatingAddButtonViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BillListViewModel()
        previewProject.bills = [previewBills, previewBills, previewBills].flatMap { $0 }
        previewProject.members = previewPersons
        viewModel.currentProject = previewProject
         
        return NavigationView {
            BillList(viewModel: viewModel)
        }
        //.modifier(FloatingAddButtonViewModifier())
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}
