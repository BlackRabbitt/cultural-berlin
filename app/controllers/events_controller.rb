# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: :show

  def index
    @events = Event.search(params)

    @pagy, @events = pagy(@events.order(created_at: :asc))
  end

  def show; end

  private

  def set_event
    @event = Event.find(params[:id])
  end
end
