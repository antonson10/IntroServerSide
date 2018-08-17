//
//  PostPersistence.swift
//  swiftServerIntro
//
//  Created by Ios Dev on 30/07/2018.
//

import Foundation
import CouchDB
import SwiftyJSON

extension Post {
    
    class Persistence {
        
        static func getAll(from database: Database,
                           callback: @escaping (_ posts: [Post]?, _ error: NSError?) -> Void) {
            database.retrieveAll(includeDocuments: true) { documents, error in
                guard let documents = documents else {
                    callback(nil, error)
                    return
                }
                var posts: [Post] = []
                for document in documents["rows"].arrayValue {
                    let id = document["id"].stringValue
                    let name = document["doc"]["name"].stringValue
                    let description = document["doc"]["description"].stringValue
                    if let post = Post(id: id, name: name, description: description) {
                        posts.append(post)
                    }
                }
                callback(posts, nil)
            }
        }
        
        static func save(_ post: Post, to database: Database,
                         callback: @escaping (_ id: String?, _ error: NSError?) -> Void) {
            getAll(from: database) { posts, error in
                guard let posts = posts else {
                    return callback(nil, error)
                }
                guard !posts.contains(post) else {
                    return callback(nil, NSError(domain: "Kitura-TIL",
                                                 code: 400,
                                                 userInfo: ["localizedDescription": "Duplicate entry"]))
                }
                database.create(JSON(["name": post.name, "description": post.description])) { id, _, _, error in
                    callback(id, error)
                }
            }
        }
        
        static func get(from database: Database, with id: String,
                        callback: @escaping (_ post: Post?, _ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(nil, error)
                }
                guard let post = Post(id: document["_id"].stringValue,
                                            name: document["name"].stringValue,
                                            description: document["description"].stringValue) else {
                                                return callback(nil, error)
                }
                callback(post, nil)
            }
        }
        
        static func delete(with id: String, from database: Database,
                           callback: @escaping (_ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(error)
                }
                let id = document["_id"].stringValue
                let revision = document["_rev"].stringValue
                database.delete(id, rev: revision) { error in
                    callback(error)
                }
            }
        }
    }
}
