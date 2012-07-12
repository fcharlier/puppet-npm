
require 'puppet/provider/package'

Puppet::Type.type(:package).provide :npm, :parent => Puppet::Provider::Package do
  desc "node.js package management with npm"

  def self.exec(op, pkg)
    s = execute ["npm #{op} -g #{pkg}"]
    s.split("\n").collect do | line |
      yield line
    end
  end

  def self.npm_list(hash)
    begin
      list = []
      exec("list", "") do | line |
        if npm_hash = npm_split(line)
          npm_hash[:provider] = :npm
          if (npm_hash[:name] == hash[:justme]) or hash[:local]
            list << npm_hash
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
    output = self.class.exec("install", resource[:name]) { | line | line }.collect
    self.fail "Could not install: #{resource[:name]}" if output.include?("npm not ok")
  end

  def uninstall
    output = self.class.exec("uninstall", resource[:name]) { | line | line }.collect
    self.fail "Could not install: #{resource[:name]}" if output.include?("npm not ok")
  end

  def query
    version = nil
    self.class.npm_list(:justme => resource[:name])
  end

end

