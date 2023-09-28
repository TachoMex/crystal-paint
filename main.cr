require "cryst_glut"
require "lib_glut"
require "./src/lib/paint"

include CrystGLUT

width = 1090
height = 600
paint = Paint.new(height, width)

window = Window.new(width, height, "Paint")

window.on_display do
  while !window.is_close_requested
    click_duration = Time.measure do
      paint.render
      window.render
      puts "Rendered"
    end
    puts "Reder took #{click_duration}"
  end
  puts "the window is closing!"
end

window.on_close do
  puts "lol"
end

window.on_mouse do |b, e, x, y|
  paint.eventoClick(b, e, x, y)
end

window.on_motion do |x, y|
  click_duration = Time.measure do
    paint.eventoArrastre(x, y)
  end
  puts "Event took #{click_duration}"
end

window.on_display do
  click_duration = Time.measure do
    paint.render
  end
  puts "Render took #{click_duration}"
end

window.on_keyboard do |k, x, y|
  paint.eventoTeclado(k, x, y)
end

LibGL.clear_color(1, 1, 1, 0)
LibGL.matrix_mode(LibGL::MatrixMode::Projection)
LibGL.ortho(0.0, width, 0.0, height, -1, 1)
LibGL.clear(LibGL::ClearBufferMask::ColorBuffer)
paint.render
LibGL.clear(LibGL::ClearBufferMask::ColorBuffer)
paint.render


window.open
