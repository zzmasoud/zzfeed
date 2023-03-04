//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import CoreData

public final class CoreDataFeedStore {
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: CoreDataFeedStore.model!, url: storeURL)
        context = container.newBackgroundContext()
    }
        
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
