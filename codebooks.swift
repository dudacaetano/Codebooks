// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

struct Nomes: Codable {
    var titulo: String
    var genero: String
    var status: String
    
}

struct Estante: Codable {
    var books: [Nomes] = []
    
    mutating func addbook(titulo: String, genero: String, status: String) {
        let novolivro = Nomes(titulo: titulo, genero: genero, status: status)
        books.append(novolivro)
        do {
            try Persistence.saveJson(self, file: "estante.json")
        } catch {
            print("Erro salvando estante", error)
        }
    }
    func listbook() {
        for livro in books {
            print(" itens \(books)")
            print("titulo: \(livro.titulo), genero: \(livro.genero), status: \(livro.status)")

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
    }
}
struct lib: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "lista todos os itens da lista",
        usage: "codebooks lib [option]",
        discussion: "List all titles that have already been saved"
    )
    
    @Flag(name: .shortAndLong, help: "todos os itens da lista que já foram salvos")
    var all: Bool = false
    
    @Option(name: .short, help: "filtra os titulos por genero")
    var generofiltro: String?
    
    @Option(name: .short, help: "filtra os tituloa por status de leitura")
    var statusfiltro: String?
    
    func run() {
        Persistence.projectName = "codebooks"
        if all {
            estante.listbook()
            for estantesbooks in estante{
                print(" itens \(estante.books)")
            }
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
        abstract: "Adiciona um novo item na lista",
        usage: "codebooks add [option][option]",
        discussion: "add a new item to the title list"
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
        /*addi(titulo: titulo, genero: genero, status: status)
         book.append(nomes(titulo: titulo, genero: genero, status: status))
         print(book)*/
    }
}
struct del: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Deleta um item da lista de titulos",
        usage: "codebooks delete [option]",
        discussion: "delete a item to the list"
    )
    @Option(name: .shortAndLong, help: "book name")
    var titulo: String
    func run() {
        Persistence.projectName = "codebooks"
        print("entrou em delete!")
    }
}
struct edit: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Edita itens que já foram salvos na lista",
        usage: "codebooks edit [option]",
        discussion: "edit a item to the list"
    )
    @Option(name: .shortAndLong, help: "book name")
    var titulo: String
    @Option(name: .long, help: "edit status book")
    var edStatus: String
    func run() {
        Persistence.projectName = "codebooks"
        print("entrou em editar!")
    }
}
