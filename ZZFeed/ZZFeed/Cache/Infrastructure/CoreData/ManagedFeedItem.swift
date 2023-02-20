//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import CoreData

@objc(ManagedFeedItem)
class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var imageURL: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedItem {
    static func items(feed: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: feed.map({ local in
            let managed = ManagedFeedItem(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.imageURL = local.imageURL
            managed.data = context.userInfo[local.imageURL] as? Data
            return managed
        }))
        context.userInfo.removeAllObjects()
        return images
    }
    
    var local: LocalFeedItem {
        return LocalFeedItem(id: id, description: imageDescription, location: location, imageURL: imageURL)
    }
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data { return data }
        
        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedItem? {
        let request = NSFetchRequest<ManagedFeedItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedItem.imageURL), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        managedObjectContext?.userInfo[imageURL] = data
    }
}
