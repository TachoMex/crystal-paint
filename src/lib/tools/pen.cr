require "./base"

module Tools
  class Pen < Base
    @active = false
    @last_x = 0
    @last_y = 0

    def on_click(b, e, x, y)
      if b == LibGLUT::LEFT_BUTTON
        if e == LibGLUT::UP
          @active = false
        elsif e == LibGLUT::DOWN
          @active = true
          @last_x = x
          @last_y = y
        end
      end
    end

    def draw(x, y)
      @canvas.line(@last_x, @last_y, x, y)
    end

    def on_motion(x, y)
      if @active
        draw(x, y)
        @last_x = x
        @last_y = y
      end
    end
  end
end
