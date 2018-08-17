//
//  Post.swift
//  swiftServerIntro
//
//  Created by Ios Dev on 30/07/2018.
//

struct Post: Codable {
    
    var id: String?
    var name: String
    var description: String
    
    init?(id: String?, name: String, description: String) {
        if name.isEmpty || description.isEmpty {
            return nil
        }
        self.id = id
        self.name = name
        self.description = description
    }
}

extension Post: Equatable {
    
    public static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description
    }
}
