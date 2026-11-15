# Páginas HTML del CRUD de productos (listado, detalle, formularios).
# Usa la misma lógica (ProductRepository) que la API JSON.
class ProductsController < ApplicationController
  rescue_from ProductRepository::NotFound do |e|
    redirect_to products_path, alert: e.message
  end

  # GET /products
  def index
    @products = repository.all
  end

  # GET /products/:id
  def show
    @product = repository.find(params[:id])
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # POST /products
  def create
    product = repository.create(product_params)
    redirect_to product_path(product.id), notice: "Producto \"#{product.nombre}\" creado."
  rescue ProductRepository::InvalidProduct
    @product = Product.new(product_params.to_h)
    @product.validate
    render :new, status: :unprocessable_content
  end

  # GET /products/:id/edit
  def edit
    @product = repository.find(params[:id])
  end

  # PATCH /products/:id
  def update
    product = repository.update(params[:id], product_params)
    redirect_to product_path(product.id), notice: "Producto actualizado."
  rescue ProductRepository::InvalidProduct
    @product = repository.find(params[:id])
    @product.assign_attributes(product_params.to_h)
    @product.validate
    render :edit, status: :unprocessable_content
  end

  # DELETE /products/:id
  def destroy
    product = repository.delete(params[:id])
    redirect_to products_path, notice: "Producto \"#{product.nombre}\" eliminado."
  end

  private

  def repository
    @repository ||= ProductRepository.new
  end

  def product_params
    params.require(:product).permit(:nombre, :descripcion, :precio, :cantidad)
  end
end
