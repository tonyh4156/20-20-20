//
//  ContentView.swift
//  20-20-20
//
//  Created by Tony Hu on 6/16/20.
//  Copyright © 2020 Tony Hu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @available(OSX 10.15.0, *)
    var body: some View {
        Text("Welcome to 20-20-20!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    @available(OSX 10.15.0, *)
    static var previews: some View {
        ContentView()
    }
}
