import Vapor
import Fluent

struct AcronymController: RouteCollection {
    func boot(router: Router)
    throws {
        let acronymsRoutes = router.grouped("api", "acronyms")
        
        func getAllHandler(_ req: Request)
        throws -> Future<[Acronym]>
        {
            return Acronym.query(on: req).all()
        }
        
        func createHandler(_ req: Request)
        throws -> Future<Acronym>
        {
            return try req.content
                .decode(Acronym.self)
                .flatMap(to: Acronym.self)
                {
                    acronym in
                    return acronym.save(on: req)
                }
        }
        
        func getHandler(_ req: Request)
        throws -> Future<Acronym>
        {
            return try req.parameters.next(Acronym.self)
        }
        
        func updateHandler(_ req: Request)
        throws -> Future<Acronym>
        {
            return try flatMap(to: Acronym.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self))
            {
                acronym, updatedAcronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req)
            }
        }
        
        func delteHandler(_ req: Request)
        throws -> Future<HTTPStatus>
        {
            return try req.parameters
                .next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
        }
        
        func searchHandler(_ req: Request)
        throws -> Future<[Acronym]>
        {
            guard let searchTerm = req.query[String.self, at: "term"]
                else
                {
                    throw Abort(.badRequest)
                }
            return try Acronym.query(on: req).group(.or)
            {   or in
                try or.filter(\.short == searchTerm)
                try or.filter(\.long == searchTerm)
            }.all()
        }
        
        acronymsRoutes.get(use: getAllHandler)
    }
}
