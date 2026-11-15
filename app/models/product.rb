# Modelo de dominio Producto.
#
# No usa base de datos (ActiveRecord): es un objeto Ruby plano con
# ActiveModel para tener atributos tipados y validaciones. La persistencia
# la maneja ProductRepository en un archivo JSON.
class Product
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  attribute :id, :integer
  attribute :nombre, :string
  attribute :descripcion, :string
  attribute :precio, :decimal
  attribute :cantidad, :integer

  validates :nombre, presence: true, length: { maximum: 100 }
  validates :descripcion, length: { maximum: 500 }
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cantidad, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Un producto con id ya está guardado; así form_with sabe si debe crear (POST)
  # o actualizar (PATCH) y genera las rutas /products/:id correctas.
  def persisted?
    id.present?
  end

  # Representación usada al guardar en el archivo JSON y al responder en la API.
  def to_h
    {
      "id" => id,
      "nombre" => nombre,
      "descripcion" => descripcion,
      "precio" => precio&.to_f,
      "cantidad" => cantidad
    }
  end

  def as_json(_options = nil)
    to_h
  end
end
