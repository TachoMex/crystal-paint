require "opengl"
require "./base"
require "./../utils"

module Tools
  class ButtonPalette < Base
    @total_tools = 0
    @background_color = Color.new(127, 127, 127)
    @width : Int32
    @height : Int32
    @pos_x : Int32
    @pos_y : Int32

    property background_color

    def initialize(c, b, @width, @height, @pos_x, @pos_y)
      super(c, b)
    end

    def render_background
      @background_color.gl_set
      draw_rectangle(@pos_x, @pos_y, @width, @height)
    end

    def draw_rectangle(pos_x, pos_y, width, height)
      LibGL.begin(LibGL::PrimitiveType::Quads)
      LibGL.vertex_2f(pos_x, pos_y)
      LibGL.vertex_2f(pos_x, pos_y + height)
      LibGL.vertex_2f(pos_x + width, pos_y + height)
      LibGL.vertex_2f(pos_x + width, pos_y)
      LibGL.end
    end

    def render_tool(i)
      y = 10 + 30 * (i // 2)
      x = 10 + 30 * (i & 1)
      draw_rectangle(@pos_x + x, @pos_y + y, 20, 20)
    end

    def clicked_button(x, y)
      (0...@total_tools).each do |i|
        yi = 10 + 30 * (i / 2) + @pos_y
        xi = 10 + 30 * (i & 1) + @pos_x
        if (in_range(xi, x, xi + 20) && in_range(yi, y, yi + 20))
          return i
        end
      end
      -1
    end

    def clicked(x, y)
      in_range(@pos_x, x, @pos_x + @width) && in_range(@pos_y, y, @pos_y + @height)
    end
  end
end
