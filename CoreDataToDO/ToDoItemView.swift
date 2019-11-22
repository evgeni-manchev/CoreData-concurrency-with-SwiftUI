//
//  ToDoItemView.swift
//  CoreDataToDO
//
//  Created by Evgeni Manchev on 10.10.19.
//  Copyright © 2019 Evgeni Manchev. All rights reserved.
//

import SwiftUI

struct ToDoItemView: View {
    var title: String = ""
    var createdAt: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(createdAt)
                    .font(.caption)
            }
        }
    }
}

struct ToDoItemView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItemView(title: "My great todo", createdAt :"Today")
    }
}
