require 'gattica'

module Orange
  class AnalyticsResource < Orange::Resource
    call_me :analytics
    
    def pageviews(route)
      r = route.to_s
      # Strip of trailing slash if present. GA doesn't like it.
      if r.rindex('/') > 0
        r[r.rindex('/')] = ''
      end
      # authenticate with the API via email/password
      ga = Gattica.new({:email => 'erictasticfosterama@gmail.com', :password => 'tailfish'})
      accounts = ga.accounts
      ga.profile_id = accounts.first.profile_id
      views = ""
      data = ga.get({ :start_date => '2009-01-01', 
                      :end_date => Time.now.localtime.strftime("%Y-%m-%d"),
                      :dimensions => ['pagePath'],
                      :metrics => ['pageviews'],
                      :filters => ['pagePath == '+route.to_s[0..-1]]
                      })
      unless data.points.length == 0
        views = data.points[0].metrics[0][:pageviews]
        views 
      else
        0
      end
    end
  end
end