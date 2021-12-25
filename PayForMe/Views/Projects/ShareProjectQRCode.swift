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
    var body: some View {
        VStack {
            Text(path).font(.caption)
            CarBode.CBBarcodeView(data: .constant(path), barcodeType: .constant(.qrCode), orientation: .constant(.up))
                .aspectRatio(contentMode: .fit)
        }
        .padding()
    }

    var path: String {
        let server = project.url.relativeString.replacingOccurrences(of: "https://", with: "")
        return "cospend://\(server)/\(project.name.lowercased())/\(project.password)"
    }
}

struct ShareProjectQRCode_Previews: PreviewProvider {
    static var previews: some View {
        ShareProjectQRCode(project: previewProject)
    }
}
