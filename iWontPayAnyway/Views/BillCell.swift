//
//  BillCell.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillCell: View {
    @State var bill: Bill
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "tortoise.fill").resizable().frame(width: 50, height: 30, alignment: .leading)
            VStack(alignment: .leading, spacing: 5) {
                Text(bill.what).font(.headline)
                HStack {
                    Text(" \(bill.payer_id) -> \(bill.owers.compactMap({$0.name}).joined(separator: ", "))").font(.subheadline)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(String(format: "%.2f €", bill.amount))").font(.headline)
                Text(bill.date).font(.caption)
            }
            }.padding()
    }
}

struct BillCell_Previews: PreviewProvider {
    static var previews: some View {
        BillCell(bill: previewBills[0])
    }
}
