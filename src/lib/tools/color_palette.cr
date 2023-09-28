require "./button_palette"

module Tools
  class ColorPalette < ButtonPalette
    @base = Color.new(255, 255, 255)

    property base

    def read_color(x, y)
      c = [0, 0, 0] of UInt8
      LibGL.read_pixels(x, y, 1, 1, LibGL::PixelFormat::RGB, LibGL::PixelType::UnsignedByte, c.to_unsafe)
      Color.new(c[0], c[1], c[2])
    end

    def on_click(b, e, x, y)
      if e == LibGLUT::DOWN
        clicked = read_color(x, y)
        return if clicked == Color.new(127, 127, 127)
        if b == LibGLUT::LEFT_BUTTON
          @base = clicked if x <= @pos_x + @width - 20
          @canvas.selected = clicked
        elsif b == LibGLUT::RIGHT_BUTTON
          @canvas.background = clicked
        end
        render_color_shades
      end
    end

    def render_colors
      padding = 10
      col_padding = 30
      total_colors = 36
      square_size = 20
      (0...total_colors).each do |i|
        r = Color.hsl(i * 360 // total_colors)
        r.gl_set
        render_tool(i)
      end
      LibGL.color_3ub(255, 255, 255)
      render_tool(total_colors)
      LibGL.color_3ub(0, 0, 0)
      render_tool(total_colors + 1)
    end

    def render_color_shades
      norm = (@base.r.to_i**2 + @base.b.to_i**2 + @base.g.to_i**2)**0.5
      ru = (@base.r.to_i + norm / 500)/norm * 2
      gu = (@base.g.to_i + norm / 500)/norm * 2
      bu = (@base.b.to_i + norm / 500)/norm * 2
      (0..500).each do |i|
        LibGL.color_3ub(ru * i > 255 ? 255 : ru * i, gu * i > 255 ? 255 : gu * i, bu * i > 255 ? 255 : bu * i)
        draw_rectangle(@pos_x + @width - 10, i * 2, 10, 2)
      end
    end

    def render
      render_background
      render_colors
      render_color_shades
    end
  end
end

# endif  // LIB_TOOLS_COLOR_PALETTE_H_
