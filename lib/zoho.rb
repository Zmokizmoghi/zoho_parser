require 'rest_client'


class Zoho

  def self.get_sub_orders
    url, auth, app_owner = Zoho.generate_url('sub_orders')
    params = { :params => { 'authtoken'    => auth,
      'scope'        => 'creatorapi',
      'zc_ownername' => app_owner,
      'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      issues  = []
      request = JSON.parse(request)
      unless request['SubOrder'].empty?
        return request['SubOrder']
      end
    end
  end

  def self.get_invoices
    url, auth, app_owner = Zoho.generate_url('get_invoices')
    params = { :params => { 'authtoken'    => auth,
                            'scope'        => 'creatorapi',
                            'zc_ownername' => app_owner,
                            'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      issues  = []
      request = JSON.parse(request)
      unless request["Invoice"].empty?
        return request['Invoice']
      end
    end
  end

  def self.get_transactions
    url, auth, app_owner = Zoho.generate_url('get_transactions')
    params = { :params => { 'authtoken'    => auth,
      'scope'        => 'creatorapi',
      'zc_ownername' => app_owner,
      'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      issues  = []
      request = JSON.parse(request)
      unless request["Transaction"].empty?
        return request['Transaction']
      end
    end
  end

  def self.get_task(id)
    url, auth, app_owner = Zoho.generate_url('issue')
    params = { :params => { 'authtoken'    => auth,
      'scope'        => 'creatorapi',
      'zc_ownername' => app_owner,
      'criteria'     => "Issue_ID = #{id}",
      'raw'          => true } }
      request              = Zoho.get(url, params)
      if request && !request.empty? && request != "{}"
        issues  = []
        request = JSON.parse(request)
        unless request["Issue"].empty?
          return request['Issue'][0]
        end
      end
  end

  def self.get_tasks
    url, auth, app_owner = Zoho.generate_url('issue')
    params = { :params => { 'authtoken'    => auth,
                            'scope'        => 'creatorapi',
                            'zc_ownername' => app_owner,
                            'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      issues  = []
      request = JSON.parse(request)
      unless request["Issue"].empty?
        return request['Issue']
      end
    end
  end

  def self.get_orders
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
            orders << order
          end
        end
      end
      orders
  end

  def self.get_users
    url, auth, app_owner = Zoho.generate_url('order')
    params = { :params => { 'authtoken'    => auth,
                            'scope'        => 'creatorapi',
                            'zc_ownername' => app_owner,
                            'raw'          => true } }
    request              = Zoho.get(url, params)
    binding.pry
    if request && !request.empty? && request != "{}"
      orders  = []
      return JSON.parse(request)
    end
  end

  def self.get_issues_for_order(zoho_id)
    url, auth, app_owner = Zoho.generate_url('orders_for_issue')
    params = { :params => { 'authtoken'    => auth,
      'scope'        => 'creatorapi',
      'zc_ownername' => app_owner,
      'criteria'     => "OrderEntity = #{zoho_id}",
      'raw'          => true } }
      request              = Zoho.get(url, params)
      if request && !request.empty? && request != "{}"
        issues  = []
        request = JSON.parse(request)
        unless request["IssueOrder"].empty?
          request["IssueOrder"].each do |issue|
            issues << issue
          end
        end
      end
      issues
  end

  def self.get_task_orders
    url, auth, app_owner = Zoho.generate_url('orders_for_issue')
    params = { :params => { 'authtoken'    => auth,
                            'scope'        => 'creatorapi',
                            'zc_ownername' => app_owner,
                            'raw'          => true } }
    request              = Zoho.get(url, params)
    if request && !request.empty? && request != "{}"
      issues  = []
      request = JSON.parse(request)
      unless request["IssueOrder"].empty?
        request["IssueOrder"].each do |issue|
          issues << issue
        end
      end
    end
    issues
  end


  private

  def self.generate_url(action)
    server    = 'https://creator.zoho.com/api/'
    protocol  = 'json/'
    auth      = '8fa0b27a260be8a7fc5a980389867d25'
    app_name  = 'tocat'
    app_owner = 'verlgoff'
    case action
    when 'orders_for_issue'
      return "#{server + protocol + app_name.downcase}/view/IssueOrder_Report", auth, app_owner
    when 'issue'
      return "#{server + protocol + app_name.downcase}/view/Issue_Report", auth, app_owner
    when 'order'
      return "#{server + protocol + app_name.downcase}/view/Order_form_Report", auth, app_owner
    when 'set_group'
      return "#{server + protocol + app_name.downcase}/view/Team_Report", auth, app_owner
    when 'get_transactions'
      return "#{server + protocol + app_name.downcase}/view/Transation_Report", auth, app_owner
    when 'get_user'
      return "#{server + protocol + app_name.downcase}/view/User_Report", auth, app_owner
    when 'get_account'
      return "#{server + protocol + app_name.downcase}/view/Account_Report", auth, app_owner
    when 'sub_orders'
      return "#{server + protocol + app_name.downcase}/view/SubOrder_Report", auth, app_owner
    when 'get_invoices'
      return "#{server + protocol + app_name.downcase}/view/Invoice_Report", auth, app_owner
    end
  end

  def self.get(url, params)
    RestClient.get(url, params) { |response, request, result, &block|
      case response.code
      when 502
        @status = response.code
        @e      = "Please, check connection between Redmine And Tocat server."
        return nil
      when 401
        @status = response.code
        @e      = "Please, check you login and password in config."
        return nil
      when 500
        @status = response.code
        @e      = "Please, check log on you tocat server."
        return nil
      when 200
        @status = response.code
        response
      when 404
        @status = response.code
        @e      = "Object not found. Looks like TOCAT sever has no record for this object."
        return nil
      else
        @status = response.code
        response.return!(request, result, &block)
      end
    }
  end
end
