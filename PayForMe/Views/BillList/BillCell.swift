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
        Grid(alignment: .leading) {
                GridRow {
                    Text(bill.what).font(.headline)
                    PersonText(person: payer)
//                        .gridColumnAlignment(.trailing)
                    Text(amountString()).font(.headline)
                        .gridColumnAlignment(.trailing)
                }
           //     .border(.green)
                
                GridRow {
                    owersTexts
                        .gridColumnAlignment(.leading)
                        .gridCellColumns(2)
                        .border(.purple, width: 5)
                    Text(DateFormatter.cospend.string(from: bill.date)).font(.subheadline)
                }.frame(maxWidth: .infinity)
            }
        .frame(maxWidth: .infinity)
            .border(.red)
    }

    func amountString() -> String {
        return "\(String(format: "%.2f", bill.amount))"
    }
    
    @ViewBuilder
    var owersTexts: some View {
        OwersView {
            ForEach(bill.owers) {
                ower in
                PersonText(person: self.realPerson(ower))
                //                if self.bill.owers.last != ower {
                //                    Text(", ")
                //                }
            }
        }
    }

    func realPerson(_ ower: Person) -> Person {
        guard let person = viewModel.currentProject.members[ower.id] else {
            return ower
        }
        return person
    }

    var payer: Person {
        viewModel.currentProject.members[bill.payer_id] ?? Person(id: 1, weight: 1, name: "Unknown", activated: true)
    }
}

struct OwersView: Layout {
    
    func allSubviewsWidth(_ subviews: Subviews) -> CGFloat {
        subviews.reduce(0) { partialResult, layoutSubview in
            partialResult + layoutSubview.sizeThatFits(.unspecified).width
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let allSubviewsWidth = allSubviewsWidth(subviews)
        if (proposal.width ?? 0 < allSubviewsWidth) {
            return CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
        }
        return CGSize(width: allSubviewsWidth, height: proposal.height ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.forEach { view in
            guard !subviews.isEmpty else { return }
            
            var x = bounds.minX
            
            for index in subviews.indices {
                let proposedSize = subviews[index].sizeThatFits(.unspecified)
                let ps = ProposedViewSize(proposedSize)
                if (proposedSize.width + x <= bounds.maxX) {
                    subviews[index].place(at: CGPoint(x: x, y: bounds.minY), anchor: .topLeading, proposal: ps)
                    x += proposedSize.width
                    x += index < subviews.count - 1 ? subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal) : 0
                } else {
                    subviews[index].place(at: CGPoint(x: x, y: bounds.minY), proposal: .zero)
                }
            }
        }
    }
    
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }
    
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
    
    func placeSubviews2(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        // Place child views.
        guard !subviews.isEmpty else { return }
      
        let maxSize = CGSize.zero //maxSize(subviews: subviews)
        let spacing = [CGFloat.infinity] //spacing(subviews: subviews)

        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var x = bounds.minX + maxSize.width / 2
      
        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            x += maxSize.width + spacing[index]
        }
    }
}

struct BillCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BillListViewModel()
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        viewModel.currentProject = previewProject
        ProjectManager.shared.currentProject = previewProject
        return BillList(viewModel: viewModel)
    }
}
