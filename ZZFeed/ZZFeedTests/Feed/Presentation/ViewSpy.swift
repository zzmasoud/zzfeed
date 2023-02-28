//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import ZZFeed

class ViewSpy: FeedView, ResourceLoadingView, ResourceErrorView {
    enum Message: Hashable {
        case display(errorMessage: String?)
        case display(isLoading: Bool)
        case display(feed: [FeedImage])
    }
    
    private(set) var messages: Set<Message> = []
    
    func display(_ viewModel: ResourceErrorViewModel) {
        messages.insert(.display(errorMessage: viewModel.message))
    }
    
    func display(_ viewModel: ResourceLoadingViewModel) {
        messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: FeedViewModel) {
        messages.insert(.display(feed: viewModel.feed))
    }
}
