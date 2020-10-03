//
//  AddProjectView.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 14.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    
    @State var isQRScanning = false
    
    var body: some View {
        NavigationView {
            if isQRScanning {
                AddProjectQRView()
            } else {
                ProjectDetailView()
            }
        }
    }
}

struct OnboardingViewView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView().environment(\.locale, .init(identifier: "de"))
    }
}
