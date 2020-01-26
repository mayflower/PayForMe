//
//  BillCell.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillCell: View {
    @Binding
    var project: Project
    
    @State
    var bill: Bill
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(bill.what).font(.headline)
                    HStack {
                        Text(paymentString()).font(.subheadline)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(amountString()).font(.headline)
                    Text(bill.date).font(.caption)
                }
            }.padding()
            Divider().background(Color.white)
        }.background(backgroundColor())
    }
    
    func paymentString() -> String {
        let payer = project.members.first{$0.id == bill.payer_id}?.name ?? bill.payer_id.description
        let owers = bill.owers.compactMap({$0.name}).joined(separator: ", ")
        return "\(payer) -> \(owers)"
    }
    
    func amountString() -> String {
        return "\(String(format: "%.2f €", bill.amount))"
    }
    
    func backgroundColor() -> Color {
        guard let payer = project.members.first(where: {$0.id == bill.payer_id}),
        let color = payer.color else { return Color.white }
        return Color(red: Double(color.r)/255, green: Double(color.g)/255, blue: Double(color.b)/255, opacity: 0.5)
    }
}

struct BillCell_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.bills = previewBills
        previewProject.members = [previewPerson]
        return BillCell(project: .constant(previewProject), bill: previewBills[0])
    }
}
