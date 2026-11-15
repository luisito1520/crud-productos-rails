require "json"
require "fileutils"

# Lógica principal del CRUD de productos.
#
# Guarda los productos en un archivo JSON con esta forma:
#   { "next_id": 3, "products": [ { "id": 1, "nombre": "...", ... }, ... ] }
#
# Cada operación lee el archivo, aplica el cambio y lo vuelve a escribir.
# Un Mutex evita que dos peticiones simultáneas se pisen al escribir.
class ProductRepository
  # Se lanza cuando se busca, actualiza o elimina un id que no existe.
  class NotFound < StandardError
    def initialize(id)
      super("No existe un producto con id #{id}")
    end
  end

  # Se lanza cuando los datos no pasan las validaciones del modelo.
  class InvalidProduct < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("Producto inválido: #{errors.full_messages.join(', ')}")
    end
  end

  EDITABLE_FIELDS = %w[nombre descripcion precio cantidad].freeze
  LOCK = Mutex.new

  attr_reader :file_path

  def initialize(file_path = Rails.configuration.x.products_file)
    @file_path = file_path.to_s
  end

  # CREATE: valida y guarda un producto nuevo con un id único autoincremental.
  def create(attrs)
    product = Product.new(permitted(attrs))
    raise InvalidProduct, product.errors unless product.valid?

    write do |data|
      product.id = data["next_id"]
      data["next_id"] += 1
      data["products"] << product.to_h
    end
    product
  end

  # READ (todos): devuelve la lista completa de productos.
  def all
    read["products"].map { |row| Product.new(row) }
  end

  # READ (uno): devuelve el producto con ese id o lanza NotFound.
  def find(id)
    row = read["products"].find { |p| p["id"] == id.to_i }
    raise NotFound, id unless row

    Product.new(row)
  end

  # UPDATE: modifica solo los campos enviados; valida antes de guardar.
  def update(id, attrs)
    product = nil
    write do |data|
      index = data["products"].index { |p| p["id"] == id.to_i }
      raise NotFound, id unless index

      product = Product.new(data["products"][index].merge(permitted(attrs)))
      raise InvalidProduct, product.errors unless product.valid?

      data["products"][index] = product.to_h
    end
    product
  end

  # DELETE: elimina el producto y lo devuelve; lanza NotFound si no existe.
  def delete(id)
    removed = nil
    write do |data|
      index = data["products"].index { |p| p["id"] == id.to_i }
      raise NotFound, id unless index

      removed = Product.new(data["products"].delete_at(index))
    end
    removed
  end

  private

  def permitted(attrs)
    attrs.to_h.stringify_keys.slice(*EDITABLE_FIELDS)
  end

  def empty_store
    { "next_id" => 1, "products" => [] }
  end

  def read
    return empty_store unless File.exist?(file_path)

    content = File.read(file_path)
    content.strip.empty? ? empty_store : JSON.parse(content)
  end

  # Lee, deja que el bloque modifique los datos y guarda solo si no hubo error.
  def write
    LOCK.synchronize do
      data = read
      yield data
      FileUtils.mkdir_p(File.dirname(file_path))
      File.write(file_path, JSON.pretty_generate(data))
    end
  end
end
