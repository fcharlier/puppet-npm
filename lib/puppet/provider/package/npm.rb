
require 'puppet/provider/package'

Puppet::Type.type(:package).provide :npm, :parent => Puppet::Provider::Package do
  desc "node.js package management with npm"

  # NOTE(fcharlier): npm & nore are currently installed in /usr/local/bin
  # if this directory is not in the path, add it.
  # It seems very ugly to me, but had the problem on some machines even with
  # /usr/local/bin in PATH in /etc/profile and puppet environment …
  if ENV['PATH'].index(/(^|:)\/usr\/local\/bin(:|$)/).nil?
      ENV['PATH'] = '/usr/local/bin:' + ENV['PATH']
  end
  optional_commands :npm => "npm"

  def self.npm_list(hash)
    begin
      list = []
      if lines = npm("list", "-g").split("\n")
        lines.each do | line |
          if npm_hash = npm_split(line)
            npm_hash[:provider] = :npm
            if (npm_hash[:name] == hash[:justme]) or hash[:local]
              list << npm_hash
            end
          end
        end
      end
      list.compact!
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list npm packages: #{detail}"
    end
    if hash[:local]
      list
    else
      list.shift
    end
  end

  def self.npm_split(desc)
    split_desc = desc.split(/ /)
    installed = split_desc[-1]
    name = installed.split(/@/)[0]
    version = installed.split(/@/)[1]
    if (name.nil? || version.nil?)
      nil
    else
      return {
        :name => name,
        :ensure => version
      }
    end
  end

  def self.instances
    npm_list(:local => true).collect do |hash|
      new(hash)
    end
  end

  def install
    output = npm("install", "-g", resource[:name]).split("\n")
    self.fail "Could not install: #{resource[:name]}" if output.include?("npm not ok")
  end

  def uninstall
    output = npm("uninstall", "-g", resource[:name]).split("\n")
    self.fail "Could not install: #{resource[:name]}" if output.include?("npm not ok")
  end

  def query
    version = nil
    self.class.npm_list(:justme => resource[:name])
  end

end

