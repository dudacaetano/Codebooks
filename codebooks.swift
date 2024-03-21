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

struct Estante: Codable {
    var books: [Database] = []
    
    mutating func addbook(titulo: String, genero: String, status: String) {
        let novolivro = Database(titulo: titulo, genero: genero, status: status)
        books.append(novolivro)
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Erro salvando estante", error)
        }
    }
    mutating func delbook(titulo: String) {
        books.removeAll(where: { $0.titulo == titulo })
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Erro salvando estante", error)
        }
    }
    mutating func editbook( titulo: String, editstatus: String) {
        if let position = books.firstIndex(where: { $0.titulo == titulo}){
            books[position].status = editstatus
        }
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Erro salvando estante", error)
        }
    }
    mutating func listbook() throws {
        var data: [[Any]] = [["📚","TITULO", "GENERO", "STATUS"]]
        let columns = [
            Column(alignment: .left, width: 10),
            Column(alignment: .center, width: 10),
            Column(alignment: .right, width: 10),
            Column(alignment: .right, width: 10)

            ]
        
        for livro in books {
            data.append([(["📗", "📕", "📘"].randomElement()!), livro.titulo, livro.genero, livro.status])
        }
        let configuration = Configuration(columns: columns)
        let table = try Table(data: data).table()
        
        print(table)
    }
    
    func filterbookgenre(genero: String){
        var genreFilterBook: [Database] = []
        var count: Int = 1
        for livro in books {
            if livro.genero.contains(genero){
                genreFilterBook.append(livro)
            }
        }
        print("These are all the books saved with the genre: \(genero)")
        for livro in genreFilterBook {
            print("livro \(count): \(livro)")
            count += 1
        }
    }
    
    func filterbookstatus(status: String) {
        var statusFilterBook: [Database] = []
        var count: Int = 1
        for livro in books {
            if livro.status.contains(status){
                statusFilterBook.append(livro)
            }
        }
        print("These are all the books saved with the status: \(status)")
        for livro in statusFilterBook {
            print("livro \(count): \(livro)")
            count += 1
        }
    }
    
    func filterBook(genero: String?, status: String? ) {
        var filterBook: [Database] = []
        if genero != nil && status == nil {
            filterBook = books.filter({ $0.genero == genero })
            print("nova array filtrada: \(filterBook)")
        }
        else if genero == nil && status != nil {
            filterBook = books.filter({ $0.status == status })
            print("nova array filtrada: \(filterBook)")
        }
        filterBook = books.filter({ $0.status == status && $0.genero == genero })
        //print("nova array filtrada: \(filterBook)")
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

    }
}
struct lib: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "list all list items",
        usage: "codebooks lib [option]",
        discussion: "List all titles that have already been saved"
    )
    
    @Flag(name: .shortAndLong, help: "list all tittles that have already been saved ")
    var all: Bool = false
    
    @Option(name: .short, help: "filter the book according to genre")
    var generofiltro: String?
    
    @Option(name: .short, help: "filter the book according to reading status")
    var statusfiltro: String?
    
    mutating func run() throws{
        Persistence.projectName = "codebooks"
        if all {
            try estante.listbook()
        }
        /*estante.filterBook(genero: generofiltro, status: statusfiltro)
        if let generofiltro, let statusfiltro {
           
        }
        */
        if generofiltro != nil && statusfiltro != nil{
            estante.filterBook(genero: generofiltro!.uppercased(), status: statusfiltro!.uppercased())
        }
        if generofiltro != nil {
            estante.filterbookgenre(genero: generofiltro!.uppercased())
            //estante.filterBook(genero: generofiltro, status: statusfiltro)
        }
        if statusfiltro != nil {
            estante.filterbookstatus(status: statusfiltro!.uppercased())
        }
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
        usage: "codebooks add [option][option]",
        discussion: "Add a new item to the book list"
    )
    @Option(name: .shortAndLong, help: "book name")
    var titulo: String
    @Option(name: .shortAndLong, help: "book status")
    var status: String
    @Option(name: .shortAndLong, help: "book genero")
    var genero: String

    func run() {
        Persistence.projectName = "codebooks"
        estante.addbook(titulo: titulo.uppercased(), genero: genero.uppercased(), status: status.uppercased())
        print("titulo: \(titulo), genero: \(genero), status: \(status)")
    }
}
struct del: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Delete a title from the book list ",
        usage: "codebooks delete [option]",
        discussion: "Delete a title to the list"
    )
    @Option(name: .shortAndLong, help: "book name")
    var titulo: String
    func run() {
        Persistence.projectName = "codebooks"
        estante.delbook(titulo: titulo.uppercased())
        print("Book have been delete from codebook-reading list!")
    }
}
struct edit: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Edit items that have been saved in the list",
        usage: "codebooks edit [option]",
        discussion: "Edit a item to the list"
    )
    @Option(name: .shortAndLong, help: "Book name")
    var titulo: String
    @Option(name: .long, help: "Edit status book")
    var edStatus: String
    func run() {
        Persistence.projectName = "codebooks"
        estante.editbook(titulo: titulo.uppercased(), editstatus: edStatus.uppercased())
        print("Update status successfully!")
    }
}
