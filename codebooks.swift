// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import Table

struct Database: Codable {
    var titulo: String
    var genero: String
    var status: String
    
    var description: String {
        return "\(["📗", "📕", "📘"].randomElement()!) \(titulo), \(genero), \(status)"
    }
}
let imgFinal =
#"""
                     ,---------------------------,
                     |  /---------------------\  |
                     | |                       | |
                     | | For more information  | |
                     | |  <Usage>              | |
                     | |     codebooks --help  | |
                     | |                       | |
                     |  \_____________________/  |
                     |___________________________|
                   ,---\_____     []     _______/------,
                 /         /______________\           /|
               /___________________________________ /  | ___
               |                                   |   |    )
               |  _ _ _                 [-------]  |   |   (
               |  o o o                 [-------]  |  /    _)_
               |__________________________________ |/     /  /
           /-------------------------------------/|      ( )/
         /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/ /
       /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/ /
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""#

struct Estante: Codable {
    var books: [Database] = []
    
    mutating func addbook(titulo: String, genero: String, status: String) {
        let novolivro = Database(titulo: titulo, genero: genero, status: status)
        books.append(novolivro)
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Error saving to bookshelf", error)
        }
    }
    mutating func delbook(titulo: String) {
        books.removeAll(where: { $0.titulo == titulo })
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Error saving to bookshelf", error)
        }
    }
    mutating func editbook( titulo: String, editstatus: String) {
        if let position = books.firstIndex(where: { $0.titulo == titulo}){
            books[position].status = editstatus
        }
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Error saving to bookshelf", error)
        }
    }
    mutating func listbook() throws {
        var data: [[Any]] = [["TÍTULO","GENERO","STATUS"]]
        for livro in books {
            data.append([livro.titulo, livro.genero, livro.status])
        }
        let table = try Table(data: data).table()
        
        print(table)
    }
    
    mutating func filterbookgenre(genero: String?) throws {
        guard let genero = genero else {
            throw NSError(domain: "InvalidParametrs", code: 400, userInfo: [NSLocalizedDescriptionKey: "Both status must be provided"])
        }
        let filteredBooks = books.filter { $0.genero == genero }
        
        guard !filteredBooks.isEmpty else {
            throw NSError(domain: "NoMatches", code: 404, userInfo: [NSLocalizedDescriptionKey: "No books found matching the provided criteria"])
        }
        
        var genreFilterBook: [[Any]] = [["TÍTULO", "GENERO", "STATUS"]]
        for livro in filteredBooks {
            genreFilterBook.append([livro.titulo, livro.genero,livro.status])
        }
        print("These are all the books saved with the genre: \(genero)")
        print(try Table(data: genreFilterBook).table())
    }
    
    mutating func filterbookstatus(status: String?) throws {
        guard let status =  status else {
            throw NSError(domain: "InvalidParametrs", code: 400, userInfo: [NSLocalizedDescriptionKey: "Both status must be provided"])
        }
        let filteredBooks = books.filter { $0.status == status }
        
        guard !filteredBooks.isEmpty else {
            throw NSError(domain: "NoMatches", code: 404, userInfo: [NSLocalizedDescriptionKey: "No books found matching the provided criteria"])
        }
        
        var statusFilterBook: [[Any]] = [["TÍTULO", "GENERO", "STATUS"]]
        for livro in filteredBooks {
            statusFilterBook.append([livro.titulo, livro.genero, livro.status])
        }
        print("These are all the books saved with the status: \(status)")
        print(try Table(data: statusFilterBook).table())
    }
    
    mutating func filterBook(genero: String?, status: String?) throws {
        guard let genero = genero, let status =  status else {
            throw NSError(domain: "InvalidParametrs", code: 400, userInfo: [NSLocalizedDescriptionKey: "Both genre and status must be provided"])
        }
        let filteredBooks = books.filter({ $0.status == status && $0.genero == genero })
        
        guard !filteredBooks.isEmpty else {
            throw NSError(domain: "NoMatches", code: 404, userInfo: [NSLocalizedDescriptionKey: "No books found matching the provided criteria"])
        }
        
        print("Filtered Books:")
        var tableBook: [[Any]] = [[ "TÍTULO", "GENERO", "STATUS"]]
        for livro in filteredBooks {
            tableBook.append([ livro.titulo, livro.genero, livro.status])
        }
        print(try Table(data: tableBook).table())
                
    }
    
    enum ANSIColors: String {
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case white = "\u{001B}[0;37m"
        case reset = "\u{001B}[0m"
    }
    func colorizeString(_ text: String, withColor color: ANSIColors) -> String {
        return color.rawValue + text + ANSIColors.reset.rawValue
    }

    func colorizeASCII(_ ascii: String, withColor color: ANSIColors) {
        print(color.rawValue + ascii + ANSIColors.reset.rawValue)
    }
    
}

var estante: Estante = (try? Persistence.readJson(file: "estante.json")) ?? Estante()

@main
struct codebooks: ParsableCommand {
    static var configuration = CommandConfiguration(
        usage: "codebooks <subcommand>",
        discussion: "This tool was developed to organize your beloved books.It works like a virtual bookshelf, where the user types the title of the book,add its status and place it in a category",
        subcommands: [lib.self, add.self, del.self, edit.self]
    )
    mutating func run() throws {
        
        let imgInicial =
        #"""
        
               .--.                                                                                                         .---
           .---|__|                                                                                                 .-.     |~~~|
        .--|===|--|_         ____   U  ___ u  ____  U _____ u   ____     U  ___ u   U  ___ u   _  __   ____         |_|     |~~~|--.
        |  |===|  |'\     U /"___|   \/"_ \/ |  _"\ \| ___"|/U | __")u    \/"_ \/    \/"_ \/  |"|/ /  / __"| u  .---!~|  .--|   |--|
        |%%|   |  |.'\    \| | u     | | | |/| | | | |  _|"   \|  _ \/    | | | |    | | | |  | ' /  <\___ \/   |===| |--|%%|   |  |
        |%%|   |  |\.'\    | |/__.-,_| |_| |U| |_| |\| |___    | |_) |.-,_| |_| |.-,_| |_| |U/| . \\u u___) |   |   | |__|  |   |  |
        |  |   |  | \  \    \____|\_)-\___/  |____/ u|_____|   |____/  \_)-\___/  \_)-\___/   |_|\_\  |____/>>  |===| |==|  |   |  |
        |  |   |__|  \.'\  _// \\      \\     |||_   <<   >>  _|| \\_       \\         \\    ,_,>> \\,-.)(  (__)|   |_|__|  |~~~|__|
        |  |===|--|   \.'\(__)(__)    (__)   (__)_) (__) (__)(__) (__)     (__)       (__)   \.)   (_/(__)      |===|~|--|%%|~~~|--|
        ^--^---'--^    `-'                                                                                      `---^-^--^--^---'--'
        """#
        
        Persistence.projectName = "codebooks"
        estante.colorizeASCII(imgInicial, withColor: .blue)
        estante.colorizeASCII("This tool was developed to organize your beloved books.It works like a virtual bookshelf, where the user types the title of the book,add its status and place it in a category", withColor: .green)
        estante.colorizeASCII("This is your virtual bookshelf at the moment", withColor: .yellow)
        try estante.listbook()
        estante.colorizeASCII(imgFinal, withColor: .red)

    }
}
struct lib: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "List all list items",
        usage: "codebooks lib [option]",
        discussion: "List all titles that have already been saved"
    )
    
    @Flag(name: .shortAndLong, help: "List all tittles that have already been saved.")
    var all: Bool = false
    
    @Option(name: .short, help: "Filter the book according to gender.")
    var generofiltro: String?
    
    @Option(name: .short, help: "Filter the book according to reading status.")
    var statusfiltro: String?
    
    mutating func run() throws{
        Persistence.projectName = "codebooks"
        if all {
            try estante.listbook()
        } 
        else if generofiltro != nil && statusfiltro != nil{
            do {
                try estante.filterBook(genero: generofiltro!.uppercased(), status: statusfiltro!.uppercased())
            } catch let error as NSError {
                print("Error when filtering books: \(error.localizedDescription)")
            }
        }
        else if generofiltro != nil {
            do {
                try estante.filterbookgenre(genero: generofiltro!.uppercased())
            } catch let error as NSError {
                print("Error when filtering books: \(error.localizedDescription)")
            }
        }
        else if statusfiltro != nil {
            do {
                try estante.filterbookstatus(status: statusfiltro!.uppercased())
            } catch let error as NSError {
                print("Error when filtering books: \(error.localizedDescription)")
            }
        }
        estante.colorizeASCII("For more information <USAGE> codebooks lib --help", withColor: .green)
        
    }
}

/*
 
 codebooks add -t duna -g scifi -s lido
   0x7b estante
    0x9c books [ duna ]
   Persistence.save(estante, path: "estante.json")
 
 Salvar estante no arquivo ~/.codebooks/estante.json
 
 codebooks add -t harry potter -g scifi -s lido
    0x31 estante = Persistence.read("estante.json")
     0x0b books [ duna ]
          books [ duna , harry potter ]
 
 */

struct add: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Add a new title to the book list",
        usage: "codebooks add [option][option][option]",
        discussion: "Add a new item to the book list"
    )
    @Option(name: .shortAndLong, help: "Book name.")
    var titulo: String
    @Option(name: .shortAndLong, help: "Book status.")
    var status: String
    @Option(name: .shortAndLong, help: "Book gender.")
    var genero: String

    func run() {
        Persistence.projectName = "codebooks"
        estante.addbook(titulo: titulo.uppercased(), genero: genero.uppercased(), status: status.uppercased())
        print("titulo: \(titulo), genero: \(genero), status: \(status)")
        estante.colorizeASCII("For more information <USAGE> codebooks add --help", withColor: .green)
    }
}
struct del: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Delete a title from the list ",
        usage: "codebooks del -t [book name] ",
        discussion: "Delete a title to the list"
    )
    @Option(name: .shortAndLong, help: "book name")
    var titulo: String
    func run() {
        Persistence.projectName = "codebooks"
        estante.delbook(titulo: titulo.uppercased())
        print("Book have been delete from codebook-reading list!")
//        estante.colorizeASCII("For more information <USAGE> codebooks del --help", withColor: .green)

    }
}
struct edit: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Edit items that have been saved in the list",
        usage: "codebooks edit -t [book name] -e [new status]",
        discussion: "Edit a item to the list"
    )
    @Option(name: .shortAndLong, help: "Book name")
    var titulo: String
    @Option(name: .shortAndLong, help: "Edit book status")
    var editing: String
    func run() {
        Persistence.projectName = "codebooks"
        estante.editbook(titulo: titulo.uppercased(), editstatus: editing.uppercased())
        print("Update status successfully!")
//        estante.colorizeASCII("For more information <USAGE> codebooks edit --help", withColor: .green)

    }
}
