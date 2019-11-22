//
//  ItemsListViewModel.swift
//  CoreDataToDO
//
//  Created by Evgeni Manchev on 20.11.19.
//  Copyright © 2019 Evgeni Manchev. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class ItemsListViewModel: ObservableObject {
    
    init() {
        fetchItems()
    }
    
    var items = [ToDoItem]() {
        didSet {
            didChange.send(self)
        }
    }
    
    private func fetchItems() {
        self.items = CoreDataManager.sharedInstance.fetchItems()
    }
    
    let didChange = PassthroughSubject<ItemsListViewModel, Never>()
}
