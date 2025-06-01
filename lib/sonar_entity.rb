module SubnauticalIntrusion
  class SonarEntity < Entity
    def initialize(**args)
      super

      @sonar_radius = 64
      @sonar_segments = 48

      @main_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds, duration: 1_000, from: 0, to: @sonar_radius, tween: :ease_in_out)
      @decay_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds + 500, duration: 1_500, from: 0, to: @sonar_radius, tween: :ease_in_out)
    end

    def draw
      super

      # Gosu.draw_arc(@position.x, @position.y, @sonar_radius * ((Gosu.milliseconds % 1000) / 1000.0), 1.0, @sonar_segments, 1, Gosu::Color::RED, @position.z)
      Gosu.draw_arc(@position.x, @position.y, @main_animator.transition, 1.0, @sonar_segments, 1, Gosu::Color::RED, @position.z)
      Gosu.draw_arc(@position.x, @position.y, @decay_animator.transition, 1.0, @sonar_segments, 1, 0x44_ff0000, @position.z)

      @main_animator.instance_variable_set("@start_time", Gosu.milliseconds) if @main_animator.complete?
      @decay_animator.instance_variable_set("@start_time", Gosu.milliseconds + 500) if @decay_animator.complete?
    end

    def entity_in_sonar_range?(entity)
      entity.position.distance(@position) <= entity.radius + @main_animator.transition
    end
  end
end
