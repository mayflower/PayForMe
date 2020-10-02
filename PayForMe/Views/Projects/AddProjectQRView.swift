//
//  AddProjectQRView.swift
//  PayForMe
//
//  Created by Max Tharr on 02.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import CarBode
import AVFoundation
import SlickLoadingSpinner

struct AddProjectQRView: View {
    @State var text = "Scanne den QR Code von Cospend"
    @State var mockCode = BarcodeData(value:"https://net.eneiluj.moneybuster.cospend/intranet.mayflower.de/test/test", type: .qr)
    @StateObject var viewmodel = AddProjectQRViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var scanningCode: [AVMetadataObject.ObjectType] = [.qr]
    
    var body: some View {
        VStack {
            if viewmodel.askForPassword {
                passwordView
            } else {
                qrCodeScanner
            }
        }
        .onReceive(viewmodel.$isProject, perform: { status in
            switch status {
                case .right:
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1)), execute: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                    break
                case .wrong:
                    scanningCode = [.qr]
                default:
                    break
            }
        })
    }
    
    var passwordView: some View {
        VStack(spacing:10) {
            Text(viewmodel.url?.absoluteString ?? "URL wrong, please scan right barcode").font(.title)
            Text(viewmodel.name).font(.title)
            SecureField("Type password here", text: $viewmodel.passwordText)
                .font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SlickLoadingSpinner(connectionState: $viewmodel.isProject)
        }.padding(40)
    }
    
    var connectIndicator: some View {
        viewmodel.isProject.image
            .frame(width: 100, height: 100, alignment: .center)
    }
    
    var qrCodeScanner: some View {
        ZStack {
            CBScanner(
                supportBarcode: $scanningCode, //Set type of barcode you want to scan
                scanInterval: .constant(5.0), //Event will trigger every 5 seconds,
                mockBarCode: .constant(mockCode)
            ){ code in
                // If we find a QR code which is an url with at least 3 components, it can be a Cospend link
                guard let url = URL(string: code.value),
                      url.pathComponents.count >= 3 else { return }
                
                scanningCode = []
                self.viewmodel.scannedCode = url
            }
            VStack {
                Spacer()
                SlickLoadingSpinner(connectionState: $viewmodel.isProject)
                    .padding(20)
                    .frame(width: UIScreen.main.bounds.width)
                    .background(Color.gray.opacity(0.5).blur(radius: 3))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct AddProjectQRView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectQRView()
    }
}
