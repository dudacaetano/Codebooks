// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

struct database: Codable {
    var titulo: String
    var genero: String
    var status: String
    
}

struct Estante: Codable {
    var books: [database] = []
    
    mutating func addbook(titulo: String, genero: String, status: String) {
        let novolivro = database(titulo: titulo, genero: genero, status: status)
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
    mutating func editbook(titulo: String, editstatus: String){
        if let position = books.firstIndex(where: { $0.titulo == titulo}){
            books[position].status = editstatus
        }
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Erro salvando estante", error)
        }
    }

    func listbook() {
        var count: Int = 1
        for livro in books {
            print("livro \(count): \(livro)")
            count += 1
        }
    }
    
    func filterbookgenre(genero: String){
        var genreFilterBook: [database] = []
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
    
    func filterbookstatus(status: String){
        var statusFilterBook: [database] = []
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
        Persistence.projectName = "codebooks"
        print("programa inicio")
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
    
    func run() {
        Persistence.projectName = "codebooks"
        if all {
            estante.listbook()
        }
        if generofiltro != nil {
            estante.filterbookgenre(genero: generofiltro!)
        }
        if statusfiltro != nil {
            estante.filterbookstatus(status: statusfiltro!)
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
        estante.addbook(titulo: titulo, genero: genero, status: status)
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
        estante.delbook(titulo: titulo)
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
        estante.editbook(titulo: titulo, editstatus: edStatus)
        print("Update status successfully!")
    }
}
