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
        MainWorkspaceView(viewModel: workspaceViewModel)
    }

}

#Preview {
    RootView()
}
