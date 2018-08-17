//
//  PostRoutes.swift
//  swiftServerIntro
//
//  Created by Ios Dev on 30/07/2018.
//

import CouchDB
import Kitura
import KituraContracts
import LoggerAPI

private var database: Database?

func initializePostRoutes(app: App) {
    database = app.database
    app.router.get("/posts", handler: getPosts)
    app.router.post("/posts", handler: addPost)
    app.router.delete("/posts", handler: deletePost)
}

private func getPosts(completion: @escaping ([Post]?, RequestError?) -> Void) {
    guard let database = database else {
        return completion(nil, .internalServerError)
    }
    Post.Persistence.getAll(from: database) { posts, error in
        return completion(posts, error as? RequestError)
    }
}

private func addPost(post: Post, completion: @escaping (Post?, RequestError?) -> Void) {
    guard let database = database else {
        return completion(nil, .internalServerError)
    }
    Post.Persistence.save(post, to: database) { id, error in
        guard let id = id else {
            return completion(nil, .notAcceptable)
        }
        Post.Persistence.get(from: database, with: id) { newPost, error in
            return completion(newPost, error as? RequestError)
        }
    }
}

private func deletePost(id: String, completion: @escaping (RequestError?) -> Void) {
    guard let database = database else {
        return completion(.internalServerError)
    }
    Post.Persistence.delete(with: id, from: database) { error in
        return completion(error as? RequestError)
    }
}
