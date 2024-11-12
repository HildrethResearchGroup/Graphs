//
//  GraphViewRepresentable.swift
//  UsingDataGraphFramework
//
//  Created by Owen Hildreth on 12/21/21.
//

import Foundation
import SwiftUI

struct GraphViewRepresentable: NSViewRepresentable {
    typealias NSViewType = GraphView
    
    var graphController: GraphController?
    
    
    
    
    func makeNSView(context: Context) -> GraphView {
        
        let graphView = GraphView(graphController)
        
        //print("Size String: \(graphController?.dgController?.canvasSettings().sizeString())")
        
        graphView.autoresizingMask = [.width, .height]
        
        return graphView
    }
    
    func updateNSView(_ nsView: GraphView, context: Context) {
        
    }
    
    @ViewBuilder
    private func noParserView() -> some View {
        VStack {
            Text("No Parser Selected")
            
        }
    }
    
}
