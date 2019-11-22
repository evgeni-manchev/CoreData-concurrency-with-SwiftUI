//
//  ContentView.swift
//  CoreDataToDO
//
//  Created by Evgeni Manchev on 30.09.19.
//  Copyright © 2019 Evgeni Manchev. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var toDoItems = ItemsListViewModel()
    @State private var newTodoItem = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("What's next?")) {
                    HStack {
                        TextField("New item", text: self.$newTodoItem)
                        Button(action: {
                            let toDoItem = ToDoItem(context: CoreDataManager.sharedInstance.saveManagedObjectContext)
                            toDoItem.title = self.newTodoItem
                            toDoItem.createdAt = Date()
                            
                            do {
                                let startTime = CFAbsoluteTimeGetCurrent()
                                
                                try CoreDataManager.sharedInstance.saveContext()
                                
                                let endTime = CFAbsoluteTimeGetCurrent()
                                let elapsedTime = (endTime - startTime) * 1000
                                print("Saving the context took \(elapsedTime) ms")
                                self.toDoItems = ItemsListViewModel()
                            } catch {
                                print(error)
                            }
                            
                            self.newTodoItem = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .imageScale(.large
                            )
                        }
                    }
                }.font(.headline)
                Section(header: Text("To Do's")) {
                    ForEach(toDoItems.items) {todoItem in
                        ToDoItemView(title: todoItem.title!, createdAt: "\(todoItem.createdAt!)")
                    }.onDelete {indexSet in
                        let deleteItem = self.toDoItems.items[indexSet.first!]
                        CoreDataManager.sharedInstance.delete(object: deleteItem)
                        self.toDoItems = ItemsListViewModel()
                    }
                }
            }
            .navigationBarTitle(Text("My List"))
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
