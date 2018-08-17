//
//  File.swift
//  swiftServerIntro
//
//  Created by Ios Dev on 30/07/2018.
//

import CouchDB
import Foundation
import Kitura
import LoggerAPI

public class App {
    var client: CouchDBClient?
    var database: Database?
    
    let router = Router()
    
    private func postInit() {
        let connectionProperties = ConnectionProperties(host: "localhost", port: 5984, secured: false)
        client = CouchDBClient(connectionProperties: connectionProperties)
        client!.dbExists("posts") { exists, _ in
            guard exists else {
                self.createNewDatabase()
                return
            }
            Log.info("Posts database located - loading...")
            self.finalizeRoutes(with: Database(connProperties: connectionProperties, dbName: "posts"))
        }
    }
    
    private func createNewDatabase() {
        Log.info("Database does not exist - creating new database")
        client?.createDB("posts") { database, error in
            guard let database = database else {
                let errorReason = String(describing: error?.localizedDescription)
                Log.error("Could not create new database: (\(errorReason)) - posts routes not created")
                return
            }
            self.finalizeRoutes(with: database)
        }
    }
    
    private func finalizeRoutes(with database: Database) {
        self.database = database
        initializePostRoutes(app: self)
        Log.info("Post routes created")
    }
    
    public func run() {
        postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
