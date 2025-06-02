module SubnauticalIntrusion
  class SonarEntity < Entity
    DEBUG_FONT = Gosu::Font.new(18)

    def initialize(**args)
      super

      @sonar_radius = 64
      @sonar_segments = 48

      @main_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds, duration: 1_000, from: 0, to: @sonar_radius, tween: :ease_in_out)
      @decay_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds + 500, duration: 1_500, from: 0, to: @sonar_radius, tween: :ease_in_out)

      @patrol_node_index = 0
    end

    def draw
      super

      # Gosu.draw_arc(@position.x, @position.y, @sonar_radius * ((Gosu.milliseconds % 1000) / 1000.0), 1.0, @sonar_segments, 1, Gosu::Color::RED, @position.z)
      Gosu.draw_arc(@position.x, @position.y, @main_animator.transition, 1.0, @sonar_segments, 1, 0xaa_ff0000, @position.z)
      Gosu.draw_arc(@position.x, @position.y, @decay_animator.transition, 1.0, @sonar_segments, 1, 0x44_ff0000, @position.z)

      @main_animator.instance_variable_set("@start_time", Gosu.milliseconds) if @main_animator.complete?
      @decay_animator.instance_variable_set("@start_time", Gosu.milliseconds + 500) if @decay_animator.complete?

      @patrol_nodes.each_with_index do |node, i|
        Gosu.draw_circle(node.x, node.y, 4, 36, i == @patrol_node_index ? Gosu::Color::GREEN : Gosu::Color::GRAY)
        DEBUG_FONT.draw_text(i, node.x, node.y, 100, 1, 1, Gosu::Color::BLACK)
      end
    end

    def update(dt, input)
      super

      return unless @patrol_nodes.size.positive?

      @position.x += @velocity.x
      @position.y -= @velocity.y

      @velocity *= @drag
      @velocity.x = 0 if @velocity.x.abs < MIN_VELOCITY
      @velocity.y = 0 if @velocity.y.abs < MIN_VELOCITY

      node = @patrol_nodes[@patrol_node_index]
      normal_direction = (@position - node).normalized

      @velocity.x -= normal_direction.x * @speed * dt
      @velocity.y += normal_direction.y * @speed * dt

      if @position.distance(node) <= @radius * 2
        @patrol_node_index += 1

        if @patrol_node_index >= @patrol_nodes.size
          @patrol_node_index = 0
        end
      end
    end

    def entity_in_sonar_range?(entity)
      entity.position.distance(@position) <= entity.radius + @main_animator.transition
    end
  end
end
