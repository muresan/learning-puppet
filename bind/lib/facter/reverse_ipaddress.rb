require 'facter'

Facter.add("reverse_ipaddress") do
  setcode do
    ipaddress = Facter.value('ipaddress')
    ipaddress.split(".").reverse.join(".")
  end
end

