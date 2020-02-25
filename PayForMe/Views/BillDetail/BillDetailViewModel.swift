//
//  BillDetailViewModel.swift
//  PayForMe
//
//  Created by Max Tharr on 24.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class BillDetailViewModel: ObservableObject {
    
    var manager = ProjectManager.shared
    var cancellable: Cancellable?
    
    @Published
    var topic = ""
    
    @Published
    var amount = ""
    
    @Published
    var selectedPayer = 1
    
    @Published
    var currentProject: Project
    
    @Published
    var currentBill: Bill
    
    var povm: PotentialOwersViewModel
    
    init(currentBill: Bill) {
        self.currentBill = currentBill
        self.currentProject = manager.currentProject
        self.povm = PotentialOwersViewModel(members: ProjectManager.shared.currentProject.members)
        self.cancellable = currentProjectChanged
        
        prefillData()
    }
    
    var currentProjectChanged: AnyCancellable {
        manager.$currentProject
            .assign(to: \.currentProject, on: self)
    }
    
    var validatedInput: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($topic, validatedAmount, povm.anyOwers)
            .map { topic, validatedAmount, anyOwers in
                return !topic.isEmpty && validatedAmount && anyOwers
        }
        .eraseToAnyPublisher()
    }
    
    var validatedAmount: AnyPublisher<Bool, Never> {
        return $amount.map { amount in
            let safeAmount = amount.replacingOccurrences(of: ",", with: ".")
            return Double(safeAmount) != nil
        }
        .eraseToAnyPublisher()
    }
    
    func createBill() -> Bill? {
        let safeAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let doubleAmount = Double(safeAmount) else {
            return nil
        }
        
        let billID = currentBill.id
        let date = currentBill.date
        
        let actualOwers = povm.actualOwers()
        
        
        return Bill(id: billID, amount: doubleAmount, what: topic, date: date, payer_id: selectedPayer, owers: actualOwers, repeat: "n", lastchanged: 0)
        
    }
    
    
    func prefillData() {
        
        self.topic = currentBill.what
        if currentBill.amount != 0 {
            self.amount = String(currentBill.amount)
        }
        
        self.selectedPayer = currentBill.payer_id
        currentBill.owers.forEach { (person) in
            if let index = povm.members.firstIndex(of: person) {
                povm.isOwing[index] = true
            }
        }
    }
}
