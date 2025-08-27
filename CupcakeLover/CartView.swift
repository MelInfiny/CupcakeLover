//
//  CartView.swift
//  CupcakeLover
//

import SwiftUI

class Cart: ObservableObject {
    static let shared = Cart()
    @Published var items: [Order] = []

    func add(_ order: Order) {
        items.append(order)
    }

    func increment(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].quantity += 1
        objectWillChange.send()
    }

    func decrement(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].quantity = max(0, items[index].quantity - 1)
        if items[index].quantity == 0 {
            items.remove(at: index)
        }
        objectWillChange.send()
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    var total: Decimal {
        items.map(\.cost).reduce(Decimal(0), +)
    }

    var isEmpty: Bool { items.isEmpty }
}

struct CartView: View {
    @ObservedObject var cart = Cart.shared
    @State private var showAddress = false
    @State private var showSuccess = false


    var body: some View {
        VStack(spacing: 0) {
            if cart.isEmpty {
                Spacer()
                ContentUnavailableView("Your cart is empty",
                                       systemImage: "cart",
                                       description: Text("Add a cupcake from the menu."))
                Spacer()
            } else {
                List {
                    ForEach(cart.items.indices, id: \.self) { i in
                        NavigationLink {
                            // Ouvrir la page du cupcake sélectionné
                            OrderView(order: cart.items[i])
                        } label: {
                            CartRow(order: cart.items[i],
                                    onMinus: { cart.decrement(at: i) },
                                    onPlus:  { cart.increment(at: i) })
                            .buttonStyle(.plain)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                cart.remove(at: IndexSet(integer: i))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .safeAreaInset(edge: .bottom) {
                    TotalBar(total: cart.total)
                        .background(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                }
                
                VStack {
                    Text("Total: \(cart.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        .font(.title3.bold())
                        .padding(.bottom, 10)
                    
                    Button {
                        showAddress = true
                    } label: {
                        Text("Proceed to Checkout")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("Your Cart")
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAddress) {
            AddressView(order: cart.items.first ?? Order()) {
                cart.items.removeAll()
                showSuccess = true
            }
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(24)
        }
        .alert("Commande validée 🎉", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Merci ! Nous préparons vos cupcakes.")
        }
    }
}

private struct CartRow: View {
    var order: Order
    var onMinus: () -> Void
    var onPlus:  () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image("cupcake-pink")
                .resizable()
                .scaledToFill()
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.quaternary, lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(Order.types[order.type])
                    .font(.headline)
    

                Text(order.cost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 0) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .frame(width: 22, height: 20)
                }
                .buttonStyle(.bordered)

                Text("\(order.quantity)")
                    .font(.body.monospacedDigit())
                    .frame(width: 36)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .frame(width: 22, height: 20)
                }
                .buttonStyle(.borderedProminent)
            }
            .clipShape(Capsule(style: .continuous))
        }
        .padding(.vertical, 6)
    }
}

private struct TotalBar: View {
    let total: Decimal

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.bold())
            }
            Spacer()
            NavigationLink {
                // on passe la 1ère commande au flow d’adresse (existant)
                AddressView(order: Cart.shared.items.first ?? Order())
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                    Text("Checkout")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(.pink.gradient))
                .foregroundStyle(.white)
                .shadow(radius: 2, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    // Créons un mock order
    let sample = Order()
    sample.type = 2
    sample.quantity = 2
    sample.extraFrosting = true
    sample.addSprinkles = true

    // Remplissons le panier partagé
    let cart = Cart.shared
    cart.items = [sample]

    return NavigationStack {
        CartView(cart: cart)
    }
}

