require "./base"

module Tools
  class Spray < Base
    @active : Bool
    @last_x : Int32
    @last_y : Int32
    @density = 0.05
    @size = 20.0
    @active = false
    @last_x = 0
    @last_y = 0

    def on_click(b, e, x, y)
      if b == LibGLUT::LEFT_BUTTON
        if e == LibGLUT::UP
          active = false
        elsif e == LibGLUT::DOWN
          active = true
          last_x = x
          last_y = y
          draw(x, y)
        end
      end
    end

    def draw(x, y)
      points = @size * @size * Math::PI * @density
      (0...points).each do
        rad = rand * @size
        theta = rand * 2 * Math::PI
        x2 = @last_x + (rad * Math.cos(theta)).to_i
        y2 = @last_y + (rad * Math.sin(theta)).to_i
        @canvas.draw(x2, y2)
      end
    end

    def on_motion(x, y)
      if @active
        @last_x = x
        @last_y = y
        draw(x, y)
      end
    end

    def heartbeat
      draw(@last_x, @last_y)
    end
  end
end
