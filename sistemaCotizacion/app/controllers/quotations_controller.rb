=begin
 * Controlador para el modelo Quotation
 * @author rails
 * @version 14-10-2017
=end

class QuotationsController < ApplicationController

=begin
 * Obtiene la cotización con el id que llega por parámetro y redirecciona para su visualización
 * @param params arreglo con los parámetros enviados por el ususario
 * @return  la cotización que va a ser mostrada al cliente
=end
  def index
    respond_to do |format|
      format.html { redirect_to quotations_path }
      format.js   {
        @quotation = Quotation.find(params[:id])
      }
    end
  end

  def show

  end

  def new
    @quotation = Quotation.new
  end

=begin
 * Crea una nueva cotización con los parámetros dados por el usuario
 * @param params arreglo con los parámetros enviados por el ususario
 * @return  la cotización creada con los parámetros del cliente, los productos disponibles para su proyecto de acuerdo a su presupuesto
 * y los servicios de instalación que requiere según su proyecto
=end
  def create
    respond_to do |format|
      format.html { redirect_to quotations_path }
      format.js   {
                    @quotation = Quotation.new(quotation_params)
                    @quotation.save!
                    @line = findLine
                    if params.dig(:quotation, :service).to_i == 1
                      if params.dig(:quotation, :name).eql?("Baño")
                        @activities = findActivities(1)
                        @activities.each do |activity|
                          @service = @quotation.services.create(quotation_id: @quotation.id, activity_id: activity.id)
                        end
                        if params.dig(:quotation, :budget).to_i >= @line.min_value and params.dig(:quotation, :budget).to_i < @line.max_value
                        @products = Product.where("product_line_id = :line_id AND construction_type_id = 1",line_id: @line.id).order('id desc')
                          @products.each do |product|
                            @article = @quotation.articles.create(quotation_id: @quotation.id, product_id: product.id, quantity: 1)
                          end
                        end
                      elsif params.dig(:quotation, :name).eql?("Cocina")
                        @activities = findActivities(2)
                        @activities.each do |activity|
                          @service = @quotation.services.create(quotation_id: @quotation.id, activity_id: activity.id)
                        end
                        if params.dig(:quotation, :budget).to_i >= @line.min_value and params.dig(:quotation, :budget).to_i < @line.max_value
                        @products = Product.where("product_line_id = :line_id AND construction_type_id = 2",line_id: @line.id).order('id desc')
                          @products.each do |product|
                            @article = @quotation.articles.create(quotation_id: @quotation.id, product_id: product.id, quantity: 1)
                          end
                        end
                      end
                    else
                      if params.dig(:quotation, :name).eql?("Baño")
                        if params.dig(:quotation, :budget).to_i >= @line.min_value and params.dig(:quotation, :budget).to_i < @line.max_value
                        @products = Product.where("product_line_id = :line_id AND construction_type_id = 1",line_id: @line.id).order('id desc')
                          @products.each do |product|
                            @article = @quotation.articles.create(quotation_id: @quotation.id, product_id: product.id, quantity: 1)
                          end
                        end
                      elsif params.dig(:quotation, :name).eql?("Cocina")
                        if params.dig(:quotation, :budget).to_i >= @line.min_value and params.dig(:quotation, :budget).to_i < @line.max_value
                        @products = Product.where("product_line_id = :line_id AND construction_type_id = 2",line_id: @line.id).order('id desc')
                          @products.each do |product|
                            @article = @quotation.articles.create(quotation_id: @quotation.id, product_id: product.id, quantity: 1)
                          end
                        end
                      end
                    end
                  }
    end
  end

=begin
 * Asigna los productos seleccionados por el cliente a su cotización
 * @param params arreglo con los productos elegidos por el usuario
 * @return  la cotización completa con los productos y servicios que desea el cliente
=end
  def updateProducts
    respond_to do |format|
      format.html { redirect_to quotations_path }
      format.js   {
        Article.where("quotation_id = :quotation", quotation: params.dig(:selected, :quotation)).destroy_all
        @quotation = Quotation.find(params.dig(:selected, :quotation))
        keys = params.keys
        keys.each do|key|
          if key.include?("product")
            value = params.values_at(key)
            @newProduct = Product.find(value)
            @newProduct.each do |pro|
              @article = @quotation.articles.create(quotation_id: @quotation.id, product_id: pro.id, quantity: 1)
            end
          end
        end
      }
    end
  end

=begin
 * Obtiene las servicios de instalación dependiendo del estado y el tipo de la obra
 * @param construction_type que construcción se quiere realizar o modificar
 * @param params todos los datos ingresados por el usuario para crear la cotización
 * @return  la cotización completa con los productos y servicios que desea el cliente
=end
  def findActivities(construction_type)
    if params.dig(:quotation, :project_status).eql?("Obra Negra")
      activities = Activity.where("construction_type_id = :construction_type AND activity_type_id <> :activity_type",{construction_type: construction_type, activity_type: 2}).order('id desc')
      return activities
    elsif params.dig(:quotation, :project_status).eql?("Obra Blanca")
      activities = Activity.where(construction_type_id: construction_type).order('id desc')
      return activities
    end
  end

=begin
 * Obtiene a que línea de productos se ajusta el presupuesto dado por el usuario
 * @param params todos los datos ingresados por el usuario para crear la cotización
 * @return la línea a la que el cliente puede acceder con base a su presupuesto
=end
  def findLine
    lines = ProductLine.all
    lines.each do |line|
      if params.dig(:quotation, :budget).to_i >= line.min_value and params.dig(:quotation, :budget).to_i < line.max_value
        return line
      end
    end
  end

=begin
 * Actualiza los datos del cliente en la cotización
 * @param params todos los datos básicos del usuario
 * @return la cotización con la información del cliente actualizada
=end
  def updateClient
    respond_to do |format|
      format.html { redirect_to quotations_path }
      format.js   {
        @quotation = Quotation.find(params.dig(:client, :quotation))
        if @quotation.client_id == 1
          @client = @quotation.create_client(first_name: params.dig(:client, :first_name), middle_name: params.dig(:client, :middle_name), first_surname: params.dig(:client, :first_surname), second_surname: params.dig(:client, :second_surname), email: params.dig(:client, :email), phone: params.dig(:client, :phone))
          @client.save!
          @quotation.update(client_id: @client.id)
        end
      }
    end
  end

=begin
 * Permite verificar si los datos necesarios para la creación de una cotización fueron suministrados
 * @param params todos los parámetros ingresados por el cliente
 * @return la cotización con la información básica
=end
  private
    def quotation_params
      params.require(:quotation).permit(:name, :floor_length, :floor_width, :wall_height, :wall_width, :budget, :project_status)
    end

end
