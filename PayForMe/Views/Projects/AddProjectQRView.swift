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
    
    var body: some View {
        if viewmodel.askForPassword {
            passwordView
        } else {
            qrCodeScanner
        }
    }
    
    var passwordView: some View {
        VStack(spacing:10) {
            Text(viewmodel.url?.absoluteString ?? "URL wrong, please scan right barcode").font(.title)
            Text(viewmodel.name).font(.title)
            SecureField("Type password here", text: $viewmodel.passwordText).font(.title)
            SlickLoadingSpinner(connectionState: $viewmodel.isProject)
        }.padding(40)
        .onReceive(viewmodel.$isProject, perform: { status in
            if status == .right {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1)), execute: {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        })
    }
    
    var connectIndicator: some View {
        viewmodel.isProject.image
            .frame(width: 100, height: 100, alignment: .center)
    }
    
    var qrCodeScanner: some View {
        ZStack {
            CBScanner(
                supportBarcode: .constant([.qr]), //Set type of barcode you want to scan
                scanInterval: .constant(5.0), //Event will trigger every 5 seconds,
                mockBarCode: .constant(mockCode)
            ){ code in
                //When the scanner found a barcode
                print(code.value)
                print("Barcode Type is", code.type.rawValue)
                self.viewmodel.scannedCode = code.value
            }
            VStack {
                Spacer()
                Text(viewmodel.text)
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
