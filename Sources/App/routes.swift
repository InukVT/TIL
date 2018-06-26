import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymsController = AcronymController()
    try router.register(collection: acronymsController)
	
	let usersController = UserController()
	try router.register(collection: usersController)
	
	let redirectController = RedirectController()
	try router.register(collection: redirectController)
}
