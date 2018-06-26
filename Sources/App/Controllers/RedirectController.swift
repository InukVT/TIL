import Vapor
import Fluent

struct RedirectController: RouteCollection {
	func boot(router: Router)
		throws
	{
		let redirectRoutes = router.grouped("redirect")
		
		redirectRoutes.get(use: getAllHandler)
		redirectRoutes.get(String.parameter, use: getHandler)
		redirectRoutes.put(Redirect.parameter, use: updateHandler)
		redirectRoutes.delete(Redirect.parameter, use: deleteHandler)
		redirectRoutes.get(Redirect.parameter, "user", use: getUserHandler)
		
		let tokenAuthMiddleware = User.tokenAuthMiddleware()
		let guardAuthMiddleware = User.guardAuthMiddleware()
		let tokenAuthGroup = redirectRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
		tokenAuthGroup.post(RedirectCreateData.self, use: createHandler)
	}
	
	func getAllHandler(_ req: Request)
		throws -> Future<[Redirect]>
	{
		return Redirect.query(on: req).all()
	}
	
	func createHandler(_ req: Request, data: RedirectCreateData)
		throws -> Future<Redirect>
	{
		let user = try req.requireAuthenticated(User.self)
		let redirect = try Redirect(title: data.title, url: data.url, userID: user.requireID())
		return redirect.save(on: req)
	}
	
	func getHandler(_ req: Request)
		throws -> Future<HTTPResponse>
	{
		//return try req.parameters.next(Redirect.self)
		let query = try req.parameters.next(String.self)
		
		return Redirect
			.query(on: req)
			.filter(\.title == query)
			.first()
			.map(to: HTTPResponse.self)
			{	redirect in
				guard let url = redirect?.url
					else
					{
						throw Abort(.notFound)
					}

				var httpRes: HTTPResponse = HTTPResponse(status: .movedPermanently)
				let httpRedirect: HTTPHeaders = HTTPHeaders([("location", url)])
				httpRes.headers = httpRedirect
				return httpRes
			}
	}
	
	func updateHandler(_ req: Request)
		throws -> Future<Redirect>
	{
		return try flatMap(to: Redirect.self,
						   req.parameters.next(Redirect.self),
						   req.content.decode(Redirect.self))
		{	redirect, updatedRedirect in
			redirect.title = updatedRedirect.title
			redirect.url = updatedRedirect.url
			redirect.userID = updatedRedirect.userID
			return redirect.save(on: req)
		}
	}
	
	func deleteHandler(_ req: Request)
		throws -> Future<HTTPStatus>
	{
		return try req.parameters
			.next(Redirect.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	func getUserHandler(_ req: Request)
		throws -> Future<User>
	{
		return try req.parameters.next(Redirect.self)
			.flatMap(to: User.self)
			{	redirect in
				redirect.user.get(on: req)
			}
	}
}

struct RedirectCreateData: Content
{
	let title: String
	let url: String
}
