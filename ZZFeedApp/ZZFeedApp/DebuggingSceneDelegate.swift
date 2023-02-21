//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

#if DEBUG
import UIKit
import ZZFeed

final class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HttpClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteClient()
    }
}

private final class AlwaysFailingHTTPClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(.failure(NSError(domain: "no connectivity", code: -1)))
        return Task()
    }
}
#endif
