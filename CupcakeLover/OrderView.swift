//
//  OrderView.swift
//  CupcakeLover
//

import SwiftUI

struct OrderView: View {
    @State private var order = Order()
    @State private var showCart = false

    // Quantités locales pour les toppings (0..3)
    @State private var sprinklesQty = 0
    @State private var frostingQty  = 0
    @State private var coulisQty    = 0

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 24) {
                Image("cupcake-pink")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width,
                           height: proxy.size.height * 0.30)
                    .clipped()
                
                Divider()
                CupcakeDescriptionView()
                    .padding(.horizontal, 15)
                
                // Toppings: 3 images en cercle + picker +/- en dessous
                HStack(spacing: 16) {
                    ToppingCirclePicker(imageName: "bublies",
                                        quantity: $sprinklesQty,
                                        range: 0...3)
                    .frame(maxWidth: .infinity)
                    
                    ToppingCirclePicker(imageName: "frosties",
                                        quantity: $frostingQty,
                                        range: 0...3)
                    .frame(maxWidth: .infinity)
                    
                    ToppingCirclePicker(imageName: "hearties",
                                        quantity: $coulisQty,
                                        range: 0...3)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 4)
                
                Spacer(minLength: 8)
                
                AddToCartBarPastel(total: totalPrice) {
                    order.addSprinkles  = sprinklesQty > 0
                    order.extraFrosting = frostingQty  > 0
                    Cart.shared.add(order)
                    showCart = true
                }
                .padding(.bottom, max(8, proxy.safeAreaInsets.bottom))
            }
            .sheet(isPresented: $showCart) { CartView() }
            .padding(.top, 16)
            .background(LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: .white, location: 0.3),
                    .init(color: Color(.systemGroupedBackground), location: 0.5),
                    .init(color: Color(.systemGroupedBackground), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
            )
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Prix d’exemple: base + 0.30 par topping sélectionné (>0)
    private var totalPrice: Double {
        3.50
        + (sprinklesQty > 0 ? 0.30 : 0)
        + (frostingQty  > 0 ? 0.30 : 0)
        + (coulisQty    > 0 ? 0.30 : 0)
    }
}

// MARK: - Sous-vue: titre et description
struct CupcakeDescriptionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pink Velvet Cupcake")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("Un cupcake irrésistiblement moelleux, nappé d’un glaçage onctueux à la vanille. Une gourmandise parfaite pour combler toutes vos envies sucrées.")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true) // ← clé
            Text("Personnalise tes toppings.")
                .foregroundStyle(.pink.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// MARK: - Sous-vue: barre du prix + add to cart

struct AddToCartBarPastel: View {
    let total: Double
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 35, weight: .medium, design: .rounded))
            }

            Spacer(minLength: 0.8)

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 20)
                .frame(minWidth: 195)
            }
            .foregroundStyle(.white)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.pink.opacity(0.6))
            )
            .shadow(radius: 4, y: 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: 620)
        .padding(.bottom, 8)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Sous-vue: image circulaire + picker +/- dessous
struct ToppingCirclePicker: View {
    let imageName: String
    @Binding var quantity: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(Circle().stroke(.quaternary, lineWidth: 1))

            HStack(spacing: 0) {
                Button {
                    quantity = max(range.lowerBound, quantity - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 36, height: 32)
                }
                .buttonStyle(.plain)

                Text("\(quantity)")
                    .font(.body.monospacedDigit())
                    .frame(width: 38)

                Button {
                    quantity = min(range.upperBound, quantity + 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 36, height: 32)
                }
                .buttonStyle(.plain)
            }
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.quaternary, lineWidth: 1))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(imageName))
        .accessibilityValue(Text("\(quantity)"))
    }
}

#Preview {
    OrderView()
}
