
//
//  AddressView.swift
//  CupcakeLover
//

import SwiftUI

struct AddressView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var order: Order

    var onConfirm: (() -> Void)? = nil
    var onGoHome:  (() -> Void)? = nil

    @State private var showConfirmAlert = false
    @FocusState private var focusedField: Field?

    enum Field { case name, street, city, zip }

    private var canPlaceOrder: Bool { order.hasValidAddress }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                formCard
                Button {
                    onConfirm?()   // vider panier, etc.
                    onGoHome?()    // CartView affichera l’alerte + retour Home
                } label: {
                    Label("Place Order", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canPlaceOrder)
                .opacity(canPlaceOrder ? 1 : 0.5)

            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    // MARK: - Subviews

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.title2)
                Text("Shipping")
                    .font(.title2).bold()
                Spacer()
            }

            Text("Entrez votre adresse de livraison pour finaliser la commande.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var formCard: some View {
        VStack(spacing: 12) {
            TextField("Name", text: $order.name)
                .textContentType(.name)
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .street }

            TextField("Street Address", text: $order.streetAddress, axis: .vertical)
                .textContentType(.fullStreetAddress)
                .lineLimit(1...3)
                .submitLabel(.next)
                .focused($focusedField, equals: .street)
                .onSubmit { focusedField = .city }

            HStack(spacing: 12) {
                TextField("City", text: $order.city)
                    .textContentType(.addressCity)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .city)
                    .onSubmit { focusedField = .zip }

                TextField("Zip", text: $order.zip)
                    .textContentType(.postalCode)
                    .keyboardType(.numbersAndPunctuation)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .zip)
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.secondary.opacity(0.1))
        )
    }
}

#Preview {
    NavigationStack {
        AddressView(order: Order(),
                    onConfirm: { print("vider panier") },
                    onGoHome:  { print("pop to root") })
    }
}
