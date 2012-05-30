class PageRequestsController < ApplicationController
  # GET /page_requests
  # GET /page_requests.json
  def index
    @page_requests = PageRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @page_requests }
    end
  end

  # GET /page_requests/1
  # GET /page_requests/1.json
  def show
    @page_request = PageRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page_request }
    end
  end

  # GET /page_requests/new
  # GET /page_requests/new.json
  def new
    @page_request = PageRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page_request }
    end
  end

  # GET /page_requests/1/edit
  def edit
    @page_request = PageRequest.find(params[:id])
  end

  # POST /page_requests
  # POST /page_requests.json
  def create
    @page_request = PageRequest.new(params[:page_request])

    respond_to do |format|
      if @page_request.save
        format.html { redirect_to @page_request, notice: 'Page request was successfully created.' }
        format.json { render json: @page_request, status: :created, location: @page_request }
      else
        format.html { render action: "new" }
        format.json { render json: @page_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /page_requests/1
  # PUT /page_requests/1.json
  def update
    @page_request = PageRequest.find(params[:id])

    respond_to do |format|
      if @page_request.update_attributes(params[:page_request])
        format.html { redirect_to @page_request, notice: 'Page request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_requests/1
  # DELETE /page_requests/1.json
  def destroy
    @page_request = PageRequest.find(params[:id])
    @page_request.destroy

    respond_to do |format|
      format.html { redirect_to page_requests_url }
      format.json { head :no_content }
    end
  end
end
