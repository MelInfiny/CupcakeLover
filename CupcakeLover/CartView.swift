//
//  CartView.swift
//  CupcakeLover
//
//

import SwiftUI

// Quantité = côté panier, pas dans Order
struct CartItem: Identifiable {
    let id = UUID()
    var order: Order
    var quantity: Int
}

class Cart: ObservableObject {
    static let shared = Cart()
    @Published var items: [CartItem] = []

    func add(_ order: Order) {
        items.append(CartItem(order: order, quantity: 1))
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

    // ---- Pricing local (plus de Order.cost) ----
    private func unitPrice(for order: Order) -> Decimal {
        var cost: Decimal = 3 // $3 par cupcake
        cost += Decimal(order.type) / 2 // complexité du type
        if order.extraFrosting { cost += 1 }     // +$1
        if order.addSprinkles  { cost += 0.5 }   // +$0.5
        if order.addCoulis     { cost += 0.5 }   // +$0.5
        return cost
    }

    private func lineTotal(for item: CartItem) -> Decimal {
        unitPrice(for: item.order) * Decimal(item.quantity)
    }

    var total: Decimal {
        items.map { lineTotal(for: $0) }.reduce(0, +)
    }

    // Expose helpers à la vue si besoin
    func unitPriceText(for order: Order) -> String {
        let code = Locale.current.currency?.identifier ?? "USD"
        return unitPrice(for: order).formatted(.currency(code: code))
    }

    func lineTotalText(for item: CartItem) -> String {
        let code = Locale.current.currency?.identifier ?? "USD"
        return lineTotal(for: item).formatted(.currency(code: code))
    }
}

struct CartView: View {
    @ObservedObject var cart = Cart.shared
    
    var onGoHome: (() -> Void)? = nil

    @State private var showAddress = false
    @State private var showSuccess = false
    

    var body: some View {
        VStack(spacing: 0) {
            if cart.items.isEmpty {
                Spacer()
                ContentUnavailableView("Your cart is empty",
                                       systemImage: "cart",
                                       description: Text("Add a cupcake from the menu."))
                Spacer()
            } else {
                List {
                    ForEach(cart.items.indices, id: \.self) { i in
                        let item = cart.items[i]
                        
                        NavigationLink {
                            // On édite la config du cupcake (type/toppings)
                            OrderView(order: item.order)
                        } label: {
                            CartRow(item: item,
                                    unitPriceText: cart.unitPriceText(for: item.order),
                                    lineTotalText: cart.lineTotalText(for: item),
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
                    TotalBar(total: cart.total, onCheckout: { showAddress = true })
                        .background(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                }
            }
        }
        .navigationTitle("Your Cart")
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAddress) {
            AddressView(
                order: cart.items.first?.order ?? Order(),
                onConfirm: { cart.items.removeAll() }, // vider le panier
                onGoHome: {
                    // on sort de la sheet et on déclenche l’alerte succès
                    showAddress = false
                    showSuccess = true
                }
            )
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(24)
        }
        .alert("Commande validée 🎉", isPresented: $showSuccess) {
            Button("OK") {
                onGoHome?()   // ← retour à Home (reset du NavigationPath dans HomeView)
            }
        } message: {
            Text("Merci ! Nous préparons vos cupcakes.")
        }
    }
}

private struct CartRow: View {
    var item: CartItem
    var unitPriceText: String
    var lineTotalText: String
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
                Text(Order.types[item.order.type])
                    .font(.title2)

                Text(lineTotalText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("Unit: \(unitPriceText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 0) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .frame(width: 22, height: 20)
                }
                .buttonStyle(.bordered)

                Text("\(item.quantity)")
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
    let onCheckout: () -> Void   // ⟵ NEW

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
            Button(action: onCheckout) {                 // ⟵ AVANT: NavigationLink
                HStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                    Text("Checkout").fontWeight(.semibold)
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
    // Mock
    let sample = Order()
    sample.type = 1
    sample.extraFrosting = true

    let cart = Cart.shared
    cart.items = [
        CartItem(order: sample, quantity: 2)
    ]

    return NavigationStack {
        CartView(cart: cart)
    }
}
