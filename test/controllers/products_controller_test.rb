require "test_helper"

# Pruebas de las páginas HTML (vistas) del CRUD.
# Cada operación tiene un caso exitoso y un caso de error.
class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @file = Rails.configuration.x.products_file
    File.delete(@file) if File.exist?(@file)
    @producto = ProductRepository.new.create(
      nombre: "Monitor", descripcion: "24 pulgadas", precio: 600_000, cantidad: 4
    )
  end

  teardown do
    File.delete(@file) if File.exist?(@file)
  end

  # ---------- LEER ----------
  test "listado muestra los productos en una tabla" do
    get products_url
    assert_response :ok
    assert_select "table tbody tr", 1
    assert_select "td", "Monitor"
    assert_select "td", "$600.000"
  end

  test "la página principal es el listado" do
    get root_url
    assert_response :ok
    assert_select "h1", "Productos"
  end

  test "listado vacío muestra un mensaje" do
    File.delete(@file)
    get products_url
    assert_select "p.empty", /No hay productos/
  end

  test "detalle muestra el producto" do
    get product_url(@producto.id)
    assert_response :ok
    assert_select "h1", "Monitor"
  end

  test "detalle de un producto inexistente redirige con mensaje de error" do
    get product_url(999)
    assert_redirected_to products_url
    follow_redirect!
    assert_select ".flash.alert", /999/
  end

  # ---------- CREAR ----------
  test "formulario de nuevo producto" do
    get new_product_url
    assert_response :ok
    assert_select "form input[name='product[nombre]']"
  end

  test "crear con datos válidos guarda y redirige al detalle" do
    post products_url, params: { product: { nombre: "Mouse", descripcion: "Inalámbrico",
                                            precio: "50000", cantidad: "20" } }
    assert_redirected_to product_url(2)
    follow_redirect!
    assert_select ".flash.notice", /creado/
    assert_equal 2, ProductRepository.new.all.size
  end

  test "crear con datos inválidos muestra los errores en español" do
    post products_url, params: { product: { nombre: "", precio: "-5", cantidad: "1" } }
    assert_response :unprocessable_content
    assert_select ".errors li", /Nombre no puede estar vacío/
    assert_select ".errors li", /Precio debe ser mayor o igual a 0/
    assert_equal 1, ProductRepository.new.all.size
  end

  # ---------- ACTUALIZAR ----------
  test "formulario de edición trae los datos actuales" do
    get edit_product_url(@producto.id)
    assert_response :ok
    assert_select "input[name='product[nombre]'][value='Monitor']"
  end

  test "actualizar con datos válidos guarda los cambios" do
    patch product_url(@producto.id), params: { product: { cantidad: "9" } }
    assert_redirected_to product_url(@producto.id)
    assert_equal 9, ProductRepository.new.find(@producto.id).cantidad
  end

  test "actualizar con datos inválidos muestra errores y no guarda" do
    patch product_url(@producto.id), params: { product: { nombre: "" } }
    assert_response :unprocessable_content
    assert_select ".errors"
    assert_equal "Monitor", ProductRepository.new.find(@producto.id).nombre
  end

  test "editar un producto inexistente redirige con error" do
    get edit_product_url(999)
    assert_redirected_to products_url
  end

  # ---------- ELIMINAR ----------
  test "eliminar borra el producto y vuelve al listado" do
    delete product_url(@producto.id)
    assert_redirected_to products_url
    follow_redirect!
    assert_select ".flash.notice", /eliminado/
    assert_empty ProductRepository.new.all
  end

  test "eliminar un producto inexistente muestra error" do
    delete product_url(999)
    assert_redirected_to products_url
    follow_redirect!
    assert_select ".flash.alert", /999/
  end
end
