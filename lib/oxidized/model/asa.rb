class ASA < Oxidized::Model

  # Cisco ASA model #
  # Only SSH supported for the sake of security

  prompt /^\r*([\w.@()-\/]+[#>]\s?)$/
  comment  '! '

  cmd :all do |cfg|
    cfg.each_line.to_a[1..-2].join
  end

  cmd :secret do |cfg|
    cfg.gsub! /enable password (\S+) (.*)/, 'enable password <secret hidden> \2'
    cfg.gsub! /username (\S+) password (\S+) (.*)/, 'username \1 password <secret hidden> \3'
    cfg
  end

  cmd 'show version' do |cfg|
    # avoid commits due to uptime / ixo-router01 up 2 mins 28 secs / ixo-router01 up 1 days 2 hours
    cfg = cfg.each_line.select { |line| not line.match /(\s+up\s+\d+\s+)|(.*days.*)/ }
    cfg = cfg.join
    comment cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'more system:running-config' do |cfg|
    cfg = cfg.each_line.to_a[3..-1].join
    cfg.gsub! /^: [^\n]*\n/, ''
    # backup any xml referenced in the configuration.
    anyconnect_profiles = cfg.scan(Regexp.new('(\sdisk0:/.+\.xml)')).flatten
    anyconnect_profiles.each do |profile|
	cfg << (comment profile + "\n" )
    	cmd ("more" + profile) do |xml|
	  cfg << (comment xml)
	end
    end
    # if DAP is enabled, also backup dap.xml
    if cfg.rindex(/dynamic-access-policy-record\s(?!DfltAccessPolicy)/)
   	cfg << (comment "disk0:/dap.xml\n")
        cmd "more disk0:/dap.xml" do |xml|
          cfg << (comment xml)
	  puts xml
        end
    end
    cfg
  end

  cfg :ssh do
    if vars :enable
      post_login do
        send "enable\n"
        send vars(:enable) + "\n"
      end
    end
    post_login 'terminal pager 0'
    pre_logout 'exit'
  end

end
