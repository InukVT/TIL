import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymsController = AcronymController()
    try router.register(collection: acronymsController)
}
