//
//  Index.swift
//  BoringAI
//
//  Created by Shydow Lee on 2019/12/31.
//  Copyright © 2019 Shydow Lee. All rights reserved.
//

import SwiftUI

struct Index: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: Classification(), label: {
                Text("Classification")
            })
        }
        
    }
}

struct Index_Previews: PreviewProvider {
    static var previews: some View {
        Index()
    }
}
