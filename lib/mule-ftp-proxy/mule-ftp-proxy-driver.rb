require 'net/ftp'
require 'securerandom'

class MuleFtpProxyDriver
  @@hidden_files = Hash.new
  @@mutex = Mutex.new

  def initialize(ip_address, port)
    @ip_address = ip_address
    @port = port
    @id = SecureRandom.uuid
    @ftp = Net::FTP.new()
  end

  def change_dir(path, &block)
    @ftp.chdir(path)
    yield true
  rescue
    yield false
  end

  def unbind
    @@mutex.synchronize do
      @@hidden_files.delete(@id)
    end
  end

  def dir_contents(path, &block)

    files = []

    @ftp.list(path) do |file|
      file_attrs = file.match(/([bcdelfmpSs-])(((r|-)(w|-)([xsStTL-]))((r|-)(w|-)([xsStTL-]))((r|-)(w|-)([xsStTL-])))\+?\s+(\d+)\s+(?:(\S+(?:\s\S+)*?)\s+)?(?:(\S+(?:\s\S+)*)\s+)?(\d+(?:,\s*\d+)?)\s+((?:\d+[-\/]\d+[-\/]\d+)|(?:\S+\s+\S+))\s+(\d+(?::\d+)?)\s+(\S*\s*.*)/)
      file_path = path + (path[-1, 1] == '/' ? '' : '/') + file_attrs[21]

      if not @@hidden_files.value? file_path

        files << EM::FTPD::DirectoryItem.new(:name => file_attrs[21],
                                             :time => Time.new(file_attrs[19] + ' ' + file_attrs[20]),
                                             :permissions => file_attrs[2],
                                             :owner => file_attrs[16],
                                             :group => file_attrs[17],
                                             :size => file_attrs[18],
                                             :directory => file_attrs[1] == 'd' ? true : false)

      end

    end

    yield files
  end

  def authenticate(user, pass, &block)
    @ftp.connect(@ip_address, @port)
    @ftp.login(user, pass)

    yield true
  rescue
    yield false
  end

  def bytes(path, &block)
    yield @ftp.size(path)
  end

  def get_file(path, &block)
    @@mutex.synchronize do
      if @@hidden_files.value? path
        yield nil
      else
        @@hidden_files[@id] = path
      end
    end

    yield @ftp.get(path, nil)

  rescue
    yield nil
  end

  def put_file(path, data, &block)
    #TODO
    yield false
  end

  def delete_file(path, &block)
    @ftp.delete(path)
    @@mutex.synchronize do
      @@hidden_files.delete(@id)
    end
    yield true
  rescue
    yield false
  end

  def delete_dir(path, &block)
    #TODO
    yield false
  end

  def rename(from, to, &block)
    #TODO
    yield false
  end

  def make_dir(path, &block)
    #TODO
    yield false
  end

end
