class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  require 'rubygems'
  require 'zip'

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)
    respond_to do |format|
      if @image.save
        Image.generate_file(@image.name,@image.postgres,@image.redis,@image.nginx,@image.ruby_ver,current_user)
        dpath=File.join(Rails.root,"/public/uploads/user/dockerfile/"+current_user.id.to_s+"/Dockerfile")
        cpath=File.join(Rails.root,"/public/uploads/user/composefile/"+current_user.id.to_s+"/docker-compose.yml")

        zipfile=File.join(Rails.root,"/public/"+@image.name+".zip")
        # send_file(dpath,:filename => "Dockerfile", :disposition => "attachment")

        Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
          zip.add("docker-compose.yml",cpath)
          zip.add("Dockerfile",dpath)
        end
        # send_file("../../files/",:filename => i.to_s)
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def generate
    @image=Image.find(params[:id])
    Image.generate_file(@image.name,@image.postgres,@image.redis,@image.nginx,@image.ruby_ver,current_user)
    dpath=File.join(Rails.root,"/public/uploads/user/dockerfile/"+current_user.id.to_s+"/Dockerfile")
    cpath=File.join(Rails.root,"/public/uploads/user/composefile/"+current_user.id.to_s+"/docker-compose.yml")

    zipfile=File.join(Rails.root,"/public/"+@image.name+".zip")
    # send_file(dpath,:filename => "Dockerfile", :disposition => "attachment")

    Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
      zip.replace("docker-compose.yml",cpath)
      zip.replace("Dockerfile",dpath)
    end
    send_file(zipfile, :disposition => "attachment")


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:name, :postgres, :nginx, :redis, :ruby_ver,:user_id)
    end
end
