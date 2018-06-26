import Vapor
import FluentPostgreSQL

final class Redirect: Codable
{
	var id: Int?
	var title: String
	var url: String
	var userID: User.ID
	
	init(title: String, url: String, userID: User.ID)
	{
		self.title = title
		self.url = url
		self.userID = userID
	}
}

extension Redirect: PostgreSQLModel {}
extension Redirect: Migration
{
	static func prepare(on connection: PostgreSQLConnection)
		-> Future<Void>
	{
		return Database.create(self, on: connection)
		{	builder in
			try addProperties(to: builder)
			try builder.reference(from: \.userID, to: \User.id)
		}
	}
}

extension Redirect: Content {}
extension Redirect: Parameter {}

extension Redirect
{
	var user: Parent<Redirect,User>
	{
		return parent(\.userID)
	}
}
