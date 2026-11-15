module ProductsHelper
  # Formatea el precio como moneda colombiana: $150.000
  def precio(valor)
    number_to_currency(valor, unit: "$", precision: 0, delimiter: ".", separator: ",")
  end

  # Valor para el campo de precio del formulario: 150000 en vez de 150000.0
  def precio_input(valor)
    return if valor.nil?

    (valor % 1).zero? ? valor.to_i : valor.to_f
  end
end
