//
//  ShareProjectQRCode.swift
//  PayForMe
//
//  Created by Max Tharr on 03.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import AVFoundation
import CarBode
import SwiftUI

struct ShareProjectQRCode: View {
    let project: Project
    
    @State var dataString = ""
    
    var body: some View {
        VStack {
            Text(dataString).font(.caption)
            CarBode.CBBarcodeView(data: $dataString, barcodeType: .constant(.qrCode), orientation: .constant(.up), onGenerated: nil)
                .aspectRatio(contentMode: .fit)
        }
        .padding()
        .onAppear {
            let server = project.url.relativeString.replacingOccurrences(of: "https://", with: "")
            dataString = "cospend://\(server)/\(project.name.lowercased())/\(project.password)"
        }
    }

}

struct ShareProjectQRCode_Previews: PreviewProvider {
    static var previews: some View {
        ShareProjectQRCode(project: previewProject)
    }
}
