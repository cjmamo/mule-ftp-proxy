module FTPPROXY
  class Server < EM::FTPD::Server
    def unbind
      @driver.unbind
    end
  end
end
