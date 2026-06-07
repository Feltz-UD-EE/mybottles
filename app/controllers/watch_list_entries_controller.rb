class WatchListEntriesController < ApplicationController
  before_action :set_watch_list_entry, only: %i[ show edit update destroy remove restore ]

  def index
    @watch_list_entries = WatchListEntry.active.includes(:watchable).order(created_at: :desc)
    @deleted_watch_list_entries_count = WatchListEntry.deleted.count
  end

  def old_entries
    @watch_list_entries = WatchListEntry.deleted.includes(:watchable).order(deleted_at: :desc)
  end

  def show
  end

  def new
    @watch_list_entry = WatchListEntry.new
    assign_watchable_from_params
  end

  def edit
  end

  def create
    @watch_list_entry = WatchListEntry.new(watch_list_entry_params)
    assign_watchable_from_params

    if @watch_list_entry.save
      redirect_to @watch_list_entry, notice: "Watch list entry was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_watchable_from_params

    if @watch_list_entry.update(watch_list_entry_params)
      redirect_to @watch_list_entry, notice: "Watch list entry was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @watch_list_entry.soft_delete!
    redirect_to watch_list_entries_url, notice: "Watch list entry was successfully removed."
  end

  def remove
    @watch_list_entry.soft_delete!
    redirect_to watch_list_entries_url, notice: "Watch list entry was successfully removed."
  end

  def restore
    @watch_list_entry.restore!
    redirect_to old_entries_watch_list_entries_url, notice: "Watch list entry was successfully restored."
  end

  private

  def set_watch_list_entry
    @watch_list_entry = WatchListEntry.find(params.expect(:id))
  end

  def watch_list_entry_params
    params.expect(watch_list_entry: %i[ description quantity caveat notes ])
  end

  def watchable_params
    params.fetch(:watch_list_entry, {}).permit(:watchable_type, :watchable_id)
  end

  def assign_watchable_from_params
    explicit_type = watchable_params[:watchable_type]
    explicit_id = watchable_params[:watchable_id]

    @watch_list_entry.watchable =
      if explicit_type == "Wine" && explicit_id.present?
        Wine.find(explicit_id)
      elsif explicit_type == "Vintage" && explicit_id.present?
        Vintage.find(explicit_id)
      else
        @watch_list_entry.watchable
      end
  end
end
