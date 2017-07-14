module Entities

  def self.init
    Entity.class_eval { attr_accessor *Component.list }

    @entity_list = []

    build_prefabs
  end


  def self.add *components
    e = Entity.new

    components.each do |component|
      e.set component, Object.const_get('Component').const_get(component.capitalize).new
    end

    yield e

    @entity_list << e

    return e
  end


  def self.prefab name
    current_prefab = @prefabs[name]

    components = current_prefab.map(&:first)

    entity = add *components do |e|
      current_prefab.each do |component, properties|
        properties.each do |property_key, property_value|
          e.get(component).send "#{property_key}=", property_value
        end unless properties.nil?
      end
    end

    yield entity
  end


  def self.each
    @entity_list.each do |e|
      yield e
    end
  end


  def self.find_by_component component
    @entity_list.find do |e|
      e.include? component
    end
  end


  def self.find_by_components *components
    @entity_list.find do |e|
      components.all? do |component|
        e.include? component
      end
    end
  end


  def self.find_at x, y
    @entity_list.find do |e|
      next unless e.include? :position
      return e if e.position.x == x and e.position.y == y
    end
    nil
  end


  def self.filter_by_component component
    @entity_list.select do |e|
      e.include? component
    end
  end


  def self.filter_by_components *components
    @entity_list.select do |e|
      components.all? do |component|
        e.include? component
      end
    end
  end


  internal def self.build_prefabs
    @prefabs = {}

    PREFABS.entity_prefabs.each do |name, components|
      @prefabs[name.to_sym] = components
    end
  end

end


class Entity

  def get component
    send component
  end


  def set component, value
    send "#{component}=", value
  end


  def include? component
    !send(component).nil?
  end


  def method_missing method
    if method[-1] == '?'
      return include? method[0...-1]
    end

    raise NoMethodError, "method '#{method}' is not found"
  end

end


module Component

  def self.list
    constants.collect { |c| const_get(c) }
             .select  { |c| c.instance_of?(Class) }
             .map     { |c| c.name.split(':').last.downcase.to_sym }
  end

end


module System; end
