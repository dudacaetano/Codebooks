// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

struct Livro {
    var titulo: String
    //var genero: String
    //var status: String
}

@main
struct codebooks: ParsableCommand {
    static var configuration = CommandConfiguration(
        usage: "codebooks <subcommand>",
        discussion: "This tool was developed to organize your beloved books.It works like a virtual bookshelf, where the user types the title of the book,add its status and place it in a category",
        subcommands: [lib.self, add.self, del.self, edit.self]
    )
    mutating func run() throws {
        
    }
}
struct lib: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "lista todos os itens da lista",
        usage: "codebooks lib [option]",
        discussion: "List all titles that have already been saved"
    )
    @Option(name: .shortAndLong, help: "todos os itens da lista que já foram salvos")
    var all: String
    @Option(name: .short, help: "filtra os titulos por genero")
    var generofiltro: String
    @Option(name: .short, help: "filtra os tituloa por status de leitura")
    var statusfiltro: String
    func run() {
        print("todos os titulos salvos na lista")
    }
}
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
    mutating func run(titulo: String) {
        var livro = [Livro(titulo: "testandocomando")]
        print("Digite o titulo do livro", livro)
        var searchTitulo: [Livro] = []
        
        for livro in livro{
            
            print(livro,"Digite o titulo do livro");
            let searchText = readLine();
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
        print("entrou em editar!")
    }
}
