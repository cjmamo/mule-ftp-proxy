module FTPPROXY

  class App < EM::FTPD::App
    def start(config_path)
      config_data = File.read(config_path)
      config = EM::FTPD::Configurator.new
      config.instance_eval(config_data)
      config.check!
      update_procline(config.name)

      EventMachine.epoll

      EventMachine::run do
        puts "Starting ftp server on 0.0.0.0:#{config.port}"
        EventMachine::start_server("0.0.0.0", config.port, FTPPROXY::Server, config.driver, *config.driver_args)

        daemonise!(config)
        change_gid(config.gid)
        change_uid(config.uid)
        setup_signal_handlers
      end
    end
  end
end