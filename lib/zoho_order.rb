class ZohoOrder
  attr_accessor :paid,
                :description,
                :sub_order,
                :number,
                :completed,
                :allocatable_budget,
                :comment,
                :zoho_id,
                :invoice,
                :team,
                :invoiced_budget,
                :budget

  def initialize(options)
    @paid = options['Paid']
    @description = options['Description']
    @sub_order = options['SubOrder']
    @number = options['Number']
    @completed = options['Completed']
    @allocatable_budget = BigDecimal( options['Allocatable_Budget'].split('$ ')[1])
    @comment = options['Comment']
    @zoho_id = options['ID']
    @invoice = options[:'Invoice']
    @team = options['Team']
    @invoiced_budget = BigDecimal(options['Invoiced_Budget'].split('$ ')[1])
    @budget = BigDecimal(options['Budget'].split('$ ')[1])
  end

  def self.get_all
    url, auth, app_owner = Zoho.generate_url('order')
    params = { :params => { 'authtoken'    => auth,
                            'scope'        => 'creatorapi',
                            'zc_ownername' => app_owner,
                            'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      orders  = []
      request = JSON.parse(request)
      unless request["OrderEntity"].empty?
        request["OrderEntity"].each do |order|
          orders << ZohoOrder.new(order)
        end
      end
    end
    orders
  end
end
