//
//  BillCell.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillCell: View {
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    var bill: Bill
    
    var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(bill.what).font(.headline)
                    HStack(spacing: 5) {
                        payerText()
                        Image(systemName: "arrow.right")
                        owersTexts()
                        }.font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    Text(amountString()).font(.headline)
                    Text(DateFormatter.cospend.string(from: bill.date)).font(.subheadline)
                }.fixedSize(horizontal: true, vertical: true)
        }
    }
    
    func payerText() -> some View {
        PersonText(person: payer)
    }
    
    func owersTexts() -> some View {
        HStack(spacing: 1) {
            ForEach(bill.owers) {
                ower in
                PersonText(person: self.realPerson(ower))
//                if self.bill.owers.last != ower {
//                    Text(", ")
//                }
            }
        }.padding(0)
    }
    
    func amountString() -> String {
        return "\(String(format: "%.2f €", bill.amount))"
    }
    
    func realPerson(_ ower: Person) -> Person {
        guard let person =  viewModel.currentProject.members[ower.id] else {
            return ower
        }
        return person
    }
    
    var payer: Person {
        get {
            viewModel.currentProject.members[bill.payer_id] ?? Person(id: 1, weight: 1, name: "Unknown", activated: true)
        }
    }
}

struct BillCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BillListViewModel()
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        viewModel.currentProject = previewProject
        return BillList(viewModel: viewModel, tabBarIndex: .BillList, hidePlusButton: .constant(false))
    }
}
