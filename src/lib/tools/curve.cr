require "./base"

module Tools
  class Curve < Base
    @points_x : StaticArray(Int32, 4)
    @points_y : StaticArray(Int32, 4)
    @points_x = StaticArray(Int32, 4).new(0)
    @points_y = StaticArray(Int32, 4).new(0)
    @state = 0
    @active = false

    def process_click(x, y)
      case @state
      when 0
        @points_x[0] = x
        @points_y[0] = y
      when 1
        @points_x[2] = x
        @points_y[2] = y
      when 2
        @points_x[3] = x
        @points_y[3] = y
      end
      @state += 1
    end

    def on_click(b, e, x, y)
      if b == LibGLUT::LEFT_BUTTON
        if e == LibGLUT::UP
          @active = false
          if @state == 3
            @state = 0
            (0...4).each do |i|
              @points_x[i] = 0
              @points_y[i] = 0
            end
            make_backup
          end
        elsif e == LibGLUT::DOWN
          @active = true
          process_click(x, y)
        end
      end
    end

    def on_motion(x, y)
      if @active
        reset_canvas()
        draw(x, y)
      end
    end

    def draw(x, y)
      @points_x[@state] = x
      @points_y[@state] = y
      case @state
      when 1
        @canvas.spline_curve(
          @points_x[0], @points_y[0],
          @points_x[1], @points_y[1],
          @points_x[1], @points_y[1],
          @points_x[1], @points_y[1])
      when 2
        @canvas.spline_curve(
          @points_x[0], @points_y[0],
          @points_x[1], @points_y[1],
          @points_x[2], @points_y[2],
          @points_x[2], @points_y[2])
      when 3
        @canvas.spline_curve(
          @points_x[0], @points_y[0],
          @points_x[1], @points_y[1],
          @points_x[2], @points_y[2],
          @points_x[3], @points_y[3])
      end
    end
  end
end
