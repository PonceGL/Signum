//
//  ContentView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI


struct RootView: View {
    @StateObject private var workspaceViewModel = WorkspaceViewModel()

    var body: some View {
        #if os(macOS)
            MacRootView(viewModel: workspaceViewModel)
        #else
            iPadRootView(viewModel: workspaceViewModel)
        #endif

    }

}

struct Placeholder: View {
    var someText: String
    var body: some View {
        VStack {
            Text(someText)
                .font(.title)
        }
    }
}

#Preview {
    RootView()
}
