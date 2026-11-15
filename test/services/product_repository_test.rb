require "test_helper"

# Pruebas unitarias de la lógica CRUD (ProductRepository).
# Cada operación tiene al menos un caso exitoso y un caso de error.
class ProductRepositoryTest < ActiveSupport::TestCase
  setup do
    @file = Rails.root.join("tmp", "repo_test_products.json")
    File.delete(@file) if File.exist?(@file)
    @repo = ProductRepository.new(@file)
  end

  teardown do
    File.delete(@file) if File.exist?(@file)
  end

  def valid_attrs
    { nombre: "Teclado", descripcion: "Teclado mecánico", precio: 150_000, cantidad: 10 }
  end

  # ---------- CREATE ----------
  test "crear: guarda el producto y le asigna un id único" do
    p1 = @repo.create(valid_attrs)
    p2 = @repo.create(valid_attrs.merge(nombre: "Mouse"))

    assert_equal 1, p1.id
    assert_equal 2, p2.id
    assert_equal 2, @repo.all.size
    assert File.exist?(@file), "debe persistir en el archivo JSON"
  end

  test "crear: falla si faltan datos obligatorios" do
    error = assert_raises(ProductRepository::InvalidProduct) do
      @repo.create(descripcion: "sin nombre ni precio")
    end
    assert_includes error.errors.attribute_names, :nombre
    assert_includes error.errors.attribute_names, :precio
    assert_empty @repo.all
  end

  test "crear: falla con precio o cantidad negativos" do
    assert_raises(ProductRepository::InvalidProduct) { @repo.create(valid_attrs.merge(precio: -1)) }
    assert_raises(ProductRepository::InvalidProduct) { @repo.create(valid_attrs.merge(cantidad: -5)) }
  end

  # ---------- READ ----------
  test "leer: lista vacía cuando no hay productos" do
    assert_equal [], @repo.all
  end

  test "leer: encuentra un producto por id" do
    creado = @repo.create(valid_attrs)
    encontrado = @repo.find(creado.id)

    assert_equal "Teclado", encontrado.nombre
    assert_equal 150_000, encontrado.precio
    assert_equal 10, encontrado.cantidad
  end

  test "leer: falla si el producto no existe" do
    assert_raises(ProductRepository::NotFound) { @repo.find(999) }
  end

  # ---------- UPDATE ----------
  test "actualizar: cambia solo los campos enviados" do
    creado = @repo.create(valid_attrs)
    @repo.update(creado.id, precio: 120_000, cantidad: 3)

    actualizado = @repo.find(creado.id)
    assert_equal 120_000, actualizado.precio
    assert_equal 3, actualizado.cantidad
    assert_equal "Teclado", actualizado.nombre
  end

  test "actualizar: falla si el producto no existe" do
    assert_raises(ProductRepository::NotFound) { @repo.update(999, nombre: "X") }
  end

  test "actualizar: falla con datos inválidos y no modifica el producto" do
    creado = @repo.create(valid_attrs)
    assert_raises(ProductRepository::InvalidProduct) { @repo.update(creado.id, nombre: "") }
    assert_equal "Teclado", @repo.find(creado.id).nombre
  end

  # ---------- DELETE ----------
  test "eliminar: borra el producto existente" do
    creado = @repo.create(valid_attrs)
    eliminado = @repo.delete(creado.id)

    assert_equal creado.id, eliminado.id
    assert_raises(ProductRepository::NotFound) { @repo.find(creado.id) }
  end

  test "eliminar: falla si el producto no existe" do
    assert_raises(ProductRepository::NotFound) { @repo.delete(999) }
  end

  test "eliminar: los ids no se reutilizan después de borrar" do
    primero = @repo.create(valid_attrs)
    @repo.delete(primero.id)
    nuevo = @repo.create(valid_attrs)
    refute_equal primero.id, nuevo.id
  end
end
