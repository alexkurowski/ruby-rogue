module Entities

  def self.init
    @entity_list = []

    build_prefabs
  end


  def self.add *components
    e = Entity.new

    components.each do |component|
      e.send "#{component}=", Object.const_get('Component').const_get(component.capitalize).new
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
        next if properties.nil?

        properties.each do |prop_key, prop_value|
          e.send(component).send("#{prop_key}=", prop_value)
        end
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


  private_class_method def self.build_prefabs
    @prefabs = {}

    PREFABS.entity_prefabs.each do |name, components|
      @prefabs[name.to_sym] = components
    end
  end

end


class Entity

  attr_accessor(
    :creature,
    :npc,
    :player,
    :position,
    :sprite
  )


  def include? component
    !send(component).nil?
  end

  def method_missing method
    if method[-1] == '?'
      include? method[0...-1]
    end
  end

end


module Component; end
module System; end
