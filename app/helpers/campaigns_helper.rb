module CampaignsHelper
  def include_paging_for_campaigns?
    @current_page > 1 and @campaigns.length == 20
  end
end
