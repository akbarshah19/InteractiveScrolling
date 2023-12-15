//
//  ContentView.swift
//  InteractiveScrolling
//
//  Created by Akbarshah Jumanazarov on 12/15/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            
            Home(safeArea: safeArea)
        }
    }
}

#Preview {
    ContentView()
}
