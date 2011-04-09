class Packager
  attr_accessor :components
  def initialize(path)
    parse_manifest path
  end
  
  def parse_manifest(path) 
    @components = []
    @provides = []
    pathinfo = Pathname.new path
    realpath = pathinfo.realpath.dirname
    if File.exists?(path) 
      manifest = YAML::load(File.new(path))
      manifest['sources'].each do |source|
        src = Unit.new source, realpath
        @components.push src
        @provides = @provides+src.provides
      end
    end
  end
  
  def validate
    @components.each do |component|
      component.requires.each do |comp|
        unless @provides.index(comp)
          puts "WARNING: The component #{comp}, required in the file #{component.filename}, has not been provided."
        end
      end
    end
  end
  
  def getComponent(prov)
    ret = nil
    @components.each do |component|
      if component.provides.index(prov)
        ret = component
      end
    end
    ret
  end
  
  def createOrder(component)
    component.requires.each do |comp|
      if @provides.index(comp)
        cp = getComponent(comp)
        createOrder(cp)
        unless @ordered.index(cp)
          @ordered.push cp
        end
      end
    end
    component.provides.each do |comp|
      cp = getComponent(comp)
      unless @ordered.index(cp)
        @ordered.push cp
      end
    end
  end
  
  def build(files=nil)
    unless files
      files = @components
    else
      f = []
      files.each do |file|
        @components.each do |comp|
          if file == comp.name
            f.push comp
          end
        end
      end
      files = f
    end
    validate
    @ordered = []
    files.each do |component|
      createOrder(component)
    end
    concated = ''
    @ordered.each do |comp|
      puts comp.name
      concated += comp.source+"\n"
    end
    CoffeeScript.compile concated, :bare=>true
  end
end
class Unit 
  attr_accessor :name, :requires, :filename, :provides, :source, :description
  @requires = []
  @provides = []
  @filename = ''
  
  
  
  def initialize(path,base)
    @filename = path
    @source = IO.readlines(base.to_s+"/"+@filename).join
    getYamlHeader()
  end
  
  def getYamlHeader
    descriptor = @source.match(/---.*?\.\.\./sm).to_s.split("\n")
    header = ''
    descriptor.each do |line|
      line.strip!
      if line != ""
        header += line+"\n"
      end
    end
    stuff = YAML::load header+"\n"
    if stuff['requires']
      @requires = if stuff['requires'].class == Array then stuff['requires'] else [stuff['requires']] end
    else
      @requires = []
    end
    if stuff['provides']
      @provides = if stuff['provides'].class == Array then stuff['provides'] else [stuff['provides']] end
    else
      @provides = []
    end    
    @name = stuff['name']
    @description = stuff['description']
  end
end
