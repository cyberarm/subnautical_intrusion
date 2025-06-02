#include <mruby.h>

#ifdef MRB_NO_STDIO
#error mruby-bin-mirb conflicts 'MRB_NO_STDIO' in your build configuration
#endif

#include <mruby/array.h>
#include <mruby/proc.h>
#include <mruby/compile.h>
#include <mruby/dump.h>
#include <mruby/string.h>
#include <mruby/variable.h>
#include <mruby/error.h>
#include <mruby/presym.h>
#include <mruby/internal.h>

#include <stdlib.h>

int main(int argc, char **argv)
{
  puts("LOADING...");

  mrb_state *mrb;

  mrb = mrb_open();
  if (mrb == NULL)
  {
    puts("FAILED TO INIT");
    fputs("Invalid mrb interpreter, exiting mirb\n", stderr);
    return EXIT_FAILURE;
  }

  puts("LOADED MRB");

  // mrb_eval(mrb, "SubnauticalIntrusion::Window.new(width: 1280, height: 800, resizable: true).show");
  struct RClass *game_module, *game_window;
  mrb_value instance;
  puts("Retrieving game module...");
  game_module = mrb_module_get(mrb, "SubnauticalIntrusion");
  puts("Retrieving game window class...");
  game_window = mrb_class_get_under(mrb, game_module, "Window");

  puts("Creating instance of window...");
  instance = mrb_class_new_instance(mrb, game_window, 0 , NULL);

  puts("Spawning window...");
  mrb_funcall(mrb, instance, "show", 0);

  mrb_close(mrb);

  return 0;
}
