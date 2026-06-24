
import Foundation
import SwiftUI
struct IngredientDropDelegate: DropDelegate {
    let item: Int
    @Binding var items: [String]
    @Binding var draggedItem: Int?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem,
              draggedItem != item else { return }
        
        let from = draggedItem
        let to = item
        
        withAnimation {
            items.move(
                fromOffsets: IndexSet(integer: from),
                toOffset: to > from ? to + 1 : to
            )
        }
        self.draggedItem = to
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
