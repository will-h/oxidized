class DataCom < Oxidized::Model

  comment '! '

  expect /^--More--\s+$/ do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    cfg.each_line.to_a[1..-2].join
    cfg.cut_head.cut_tail
  end

  cmd 'show firmware' do |cfg|
    comment cfg
  end

  cmd 'show system' do |cfg|
    comment cfg
  end

  cmd 'show running-config' do |cfg|
    cfg.cut_head
  end

  cfg :telnet, :ssh do
    username /login:\s$/
    password /^Password:\s$/
    pre_logout 'exit'
  end

end
