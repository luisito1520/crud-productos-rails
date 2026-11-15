module Api
  # API REST JSON para el CRUD de productos.
  #
  #   GET    /api/products       -> listar
  #   GET    /api/products/:id   -> ver uno
  #   POST   /api/products       -> crear
  #   PATCH  /api/products/:id   -> actualizar
  #   DELETE /api/products/:id   -> eliminar
  class ProductsController < ActionController::API
    rescue_from ProductRepository::NotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ProductRepository::InvalidProduct do |e|
      render json: { error: "Datos inválidos", detalles: e.errors.full_messages },
             status: :unprocessable_content
    end

    def index
      render json: repository.all
    end

    def show
      render json: repository.find(params[:id])
    end

    def create
      render json: repository.create(product_params), status: :created
    end

    def update
      render json: repository.update(params[:id], product_params)
    end

    def destroy
      repository.delete(params[:id])
      head :no_content
    end

    private

    def repository
      @repository ||= ProductRepository.new
    end

    def product_params
      params.require(:product).permit(:nombre, :descripcion, :precio, :cantidad)
    end
  end
end
