require "test_helper"

# Pruebas de la API REST: verifican códigos HTTP y respuestas JSON
# para el caso exitoso y el caso de error de cada operación.
class Api::ProductsControllerTest < ActionDispatch::IntegrationTest
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

  test "GET /api/products lista los productos" do
    get api_products_url, as: :json
    assert_response :ok
    assert_equal 1, response.parsed_body.size
    assert_equal "Monitor", response.parsed_body.first["nombre"]
  end

  test "GET /api/products/:id devuelve el producto" do
    get api_product_url(@producto.id), as: :json
    assert_response :ok
    assert_equal @producto.id, response.parsed_body["id"]
  end

  test "GET /api/products/:id responde 404 si no existe" do
    get api_product_url(999), as: :json
    assert_response :not_found
    assert_match "999", response.parsed_body["error"]
  end

  test "POST /api/products crea un producto" do
    post api_products_url, params: { product: { nombre: "Mouse", descripcion: "Inalámbrico",
                                            precio: 50_000, cantidad: 20 } }, as: :json
    assert_response :created
    assert_equal 2, response.parsed_body["id"]
  end

  test "POST /api/products responde 422 con datos inválidos" do
    post api_products_url, params: { product: { nombre: "", precio: -10, cantidad: 1 } }, as: :json
    assert_response :unprocessable_content
    assert_not_empty response.parsed_body["detalles"]
  end

  test "PATCH /api/products/:id actualiza el producto" do
    patch api_product_url(@producto.id), params: { product: { cantidad: 9 } }, as: :json
    assert_response :ok
    assert_equal 9, response.parsed_body["cantidad"]
  end

  test "PATCH /api/products/:id responde 404 si no existe" do
    patch api_product_url(999), params: { product: { cantidad: 9 } }, as: :json
    assert_response :not_found
  end

  test "DELETE /api/products/:id elimina el producto" do
    delete api_product_url(@producto.id), as: :json
    assert_response :no_content
    get api_product_url(@producto.id), as: :json
    assert_response :not_found
  end

  test "DELETE /api/products/:id responde 404 si no existe" do
    delete api_product_url(999), as: :json
    assert_response :not_found
  end
end
