#!/usr/bin/env ruby

require './lib/BearLibTerminal'

Terminal.open()

Terminal.print(1, 1, 'Hello World!')
Terminal.refresh()

while Terminal.read() != Terminal::TK_CLOSE
end

Terminal.close()
