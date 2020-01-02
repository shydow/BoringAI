//
//  Classification.swift
//  BoringAI
//
//  Created by Shydow Lee on 2020/1/2.
//  Copyright © 2020 Shydow Lee. All rights reserved.
//

import SwiftUI

struct Classification: View {
    @ObservedObject var classificationVM = ClassificationViewModel()
    
    @State var isRunning = false
    
    var body: some View {
        VStack {
            if isRunning {
                Text(self.classificationVM.result.identity + " " + String(self.classificationVM.result.confidance))
                Spacer()
                self.classificationVM.preview
                Button(action: {
                    self.classificationVM.stopClassify()
                    self.isRunning = false
                }, label: {
                    Text("Stop")
                })
            } else {
                Text("Icon")
                Spacer()
                Button(action: {
                    self.classificationVM.startClassify()
                    self.isRunning = true
                }, label: {
                    Text("Start")
                })
            }
        }
    }
}

struct Classification_Previews: PreviewProvider {
    static var previews: some View {
        Classification()
    }
}
