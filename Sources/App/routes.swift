import Fluent
import Vapor
//import shared

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.webSocket("echo") { req, ws in
        print("Connected \(req)")

        ws.onText { (ws, text) in
            print(text)
        }
        
        ws.onBinary { (ws, binary) in
            print(binary)
            
            do {
                let message = try JSONDecoder().decode(Message.self, from: binary)
                try MessageController.process(message, with: ws)
            } catch {
                print("Error: Failed to Decode Json")
            }
        }
        
        ws.onClose.whenComplete { [weak ws] (res) in
            guard let ws = ws else { return }
            print(ws.closeCode ?? "Socket Closed")
        }
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.delete("todos", ":todoID", use: todoController.delete)
}
